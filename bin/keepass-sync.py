#!/usr/bin/env python3

import logging
import subprocess
import json
import hashlib

from datetime import datetime, timezone
from pathlib import Path
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer


XDG_CONFIG_HOME = Path(Path.home() / "projects/madrzak/dotfiles/bin")
XDG_DATA_HOME = Path(Path.home() / "projects/madrzak/dotfiles/bin")

# XDG_CONFIG_HOME = Path(Path.home() / ".config/keepass-sync").resolve()
# XDG_DATA_HOME = Path(Path.home() / ".local/state/keepass-sync/").resolve()

# rclone md5sum secret-share:the_bundle.kdbx
# rclone sync source dest
# rclone check source dest
# rclone copyto source dest


class JsonFile:

    def __init__(self, path: Path):
        self.path = path
        self.data = {}

    def load(self):
        self.data = json.loads(self.path.read_text())

    def store(self):
        with self.path.open("w", encoding="utf-8") as fd:
            json.dump(self.data, fd, indent=2, sort_keys=True)


class UserInterface:
    def __init__(self, app_name):
        self.app_name = app_name
        pass

    def info(self, title, body):
        subprocess.Popen([
            "notify-send",
            f"--app-name='{self.app_name}'",
            "--urgency=normal",
            "--icon=emblem-synchronizing",
            title,
            body,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
            )

    def error(self, title, body):
        subprocess.Popen([
            "notify-send",
            f"--app-name='{self.app_name}'",
            "--urgency=critical",
            "--icon=emblem-important",
            title,
            body,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
            )

    def conflict(self, text):
        result = subprocess.run([
            "zenity",
            "--question",
            f"--title={self.app_name}",
            f"--text={text}",
            "--ok-label=Remote",
            "--cancel-label=Local",
            "--extra-button=Manual",
            "--timeout=30",
            "--icon=emblem-important",
            "--no-wrap",
            ],
            text=True,
            capture_output=True,
            )
        # 0 -> use remote, copy locally
        # 1 -> use local
        # 5 -> manually
        if result.returncode == 0:
            return 0
        if "Manual" in result.stdout:
            return 5
        return 1

    def info_copyable(self, text, path):
        result = subprocess.run([
            "zenity",
            "--entry",
            f"--title={self.app_name}",
            f"--text={text}",
            f"--entry-text={str(path)}",
            "--timeout=30",
            ],
            text=True,
            capture_output=True,
            )
        logging.info(result)
        logging.info(result.stdout)
        logging.warning(result.stderr)
        return result.returncode


class RClone:
    def __init__(self, storage: str):
        self.storage = storage

    def md5sum(self, filename: str) -> str:
        rpath = self.storage + ":" + filename
        result = subprocess.run(["rclone", "md5sum", rpath],
                                text=True,
                                capture_output=True,
                                )
        return result.stdout.split()[0]

    def mtime(self, filename: str) -> int:
        rpath = self.storage + ":" + filename
        result = subprocess.run(["rclone", "lsjson", "-l", rpath],
                                text=True,
                                capture_output=True,
                                )
        if result.returncode == 0:
            data = json.loads(result.stdout)
            mod_time = data[0]["ModTime"]
            mtime = datetime.fromisoformat(mod_time.replace("Z", "+00:00")) \
                .astimezone(timezone.utc)
        return mtime

    def from_remote(self, source, dest):
        rpath = self.storage + ":" + source
        result = subprocess.run(["rclone", "copyto", rpath, str(dest)],
                                text=True,
                                capture_output=True,
                                )
        return result.returncode

    def copyto(self, source, dest):
        rpath = self.storage + ":" + dest
        result = subprocess.run(["rclone", "copyto", str(source), rpath],
                                text=True,
                                capture_output=True,
                                )
        return result.returncode


class FileModifiedHandler(FileSystemEventHandler):
    def __init__(self, rclone: RClone,
                 local_file: Path,
                 meta: JsonFile,
                 ui: UserInterface) -> None:
        super().__init__()
        self.rclone = rclone
        self.lfile = local_file
        self.rfile = local_file.name
        self.meta = meta
        self.ui = ui

        try:
            meta.load()
        except Exception:
            logging.warning("can't load metadata")
            self.meta.data = {
                "md5sum": None,
                "mtime": None,
                }

    def on_modified(self, event):
        if Path(event.src_path).resolve() == self.lfile:
            self.upload()

    def on_moved(self, event):
        if Path(event.dest_path).resolve() == self.lfile:
            self.upload()

    def _handle_conflict(self):
        logging.error("conflict: remote and local modified")
        answer = self.ui.conflict(
            f"Both local and remote copy of {self.rfile} changed.\n"
            "How would you like to resolve it:"
            )
        if answer == 5:
            cfile = self.lfile.with_name(self.lfile.name + ".remote")
            self.fetch(cfile)
            self.ui.info_copyable("Remote file has been saved as:", cfile)
            logging.info("restarting due to manual conflict resolution")
            exit(1)
        elif answer == 1:
            logging.info("user decided to use local file")
            self.upload()
        # TODO: use remote

    def sync(self):
        lmd5sum = hashlib.md5(self.lfile.read_bytes()).hexdigest()
        if self.meta.data["md5sum"] != lmd5sum:
            if self.meta.data["md5sum"] != self.rclone.md5sum(self.rfile):
                self._handle_conflict()
            else:
                logging.warning("local file modified externally")
                self.upload()
        elif self.meta.data["md5sum"] != self.rclone.md5sum(self.rfile):
            logging.info("local and remote files differ")
            self.upload()
        else:
            logging.info("remote and local file are the same")

    def fetch(self, target: Path = None):
        if target is None:
            target = self.lfile
        self.rclone.from_remote(self.rfile, target)
        logging.info("file: '%s' downloaded as '%s'", self.rfile, target)

    def upload(self):
        self.rclone.copyto(self.lfile, self.rfile)
        self.meta.data["mtime"] = str(self.rclone.mtime(self.rfile))
        self.meta.data["md5sum"] = self.rclone.md5sum(self.rfile)
        self.meta.store()
        self.ui.info("Sync", f"{self.lfile} has been sync")
        logging.info("file: '%s' uploaded to remote", self.rfile)


# meta_file = Path(XDG_DATA_HOME / "the_bundle.kdbx").resolve()


def main():
    # TODO: rclone use keepassxc to get secrets to decrypt storage. Hence, even
    # if
    # database is out of sync, keepassxc must first unlock storage. Having that
    # sync service can fetch credentials and do a proper sync. This can be done
    # via D-Bus api.

    db_file = Path(Path.home() / "SynologyDrive" / "the_bundle.kdbx").resolve()
    meta_file = Path(XDG_DATA_HOME / "dbfile.json").resolve()

    r_disk = "secret-share"

    logging.info("db: %s", db_file)
    logging.info("meta: %s", meta_file)
    logging.info("remote: %s", r_disk)

    rclone = RClone(r_disk)
    meta = JsonFile(meta_file)
    ui = UserInterface("KeePassXC sync service")

    handler = FileModifiedHandler(rclone, db_file, meta, ui)
    handler.sync()

    obs = Observer()
    obs.schedule(handler, str(db_file.parent))
    obs.start()

    try:
        obs.join()
    except KeyboardInterrupt:
        obs.stop()
        obs.join()

    return 0


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="[%(levelname)s] %(message)s")
    raise SystemExit(main())
