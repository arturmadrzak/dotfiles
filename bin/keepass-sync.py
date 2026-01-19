#!/usr/bin/env python3

import logging
import subprocess
import json
import hashlib
import secretstorage
import time
import os

from datetime import datetime, timezone
from pathlib import Path
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from contextlib import closing
from typing import Sequence

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
            "expire-time=10000",
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
            "--ok-label=Download remote",
            "--cancel-label=Upload local",
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
    def __init__(self, storage: str, password: str = None):
        self.storage = storage
        self.password = password

    def _run_rclone(self, *args: str):
        env = os.environ.copy()
        if self.password is not None:
            env["RCLONE_CONFIG_PASS"] = self.password
        cmd: Sequence[str] = ["rclone", *args]
        return subprocess.run(cmd, env=env, text=True, capture_output=True)

    def md5sum(self, filename: str) -> str:
        rpath = self.storage + ":" + filename
        result = self._run_rclone("md5sum", rpath)
        return result.stdout.split()[0]

    def mtime(self, filename: str) -> int:
        rpath = self.storage + ":" + filename
        result = self._run_rclone("lsjson", "-l", rpath)
        if result.returncode == 0:
            data = json.loads(result.stdout)
            mod_time = data[0]["ModTime"]
            mtime = datetime.fromisoformat(mod_time.replace("Z", "+00:00")) \
                .astimezone(timezone.utc)
        return mtime

    def from_remote(self, source, dest):
        rpath = self.storage + ":" + source
        result = self._run_rclone("copyto", rpath, str(dest))
        return result.returncode

    def copyto(self, source, dest):
        rpath = self.storage + ":" + dest
        result = self._run_rclone("copyto", str(source), rpath)
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
            self.sync()

    def on_moved(self, event):
        if Path(event.dest_path).resolve() == self.lfile:
            self.sync()

    # TODO: resolve, nope, manuall action needed. XC doesn't have option of database merging
    # as mobile app has :/
    def _handle_conflict(self):
        logging.error("conflict: remote and local modified")
        rtime = self.rclone.mtime(self.rfile)
        lrtime = self.meta["mtime"]
        ltime = datetime.fromtimestamp(self.lfile.stat().st_mtime,
                                       tz=timezone.utc)
        answer = self.ui.conflict(
            f"Both local and remote copy of {self.rfile} changed.\n"
            f"remote: {rtime}\n"
            f"local: {ltime} (based on: {lrtime}\n"
            "How would you like to resolve it:"
            )
        if answer == 5:
            cfile = self.lfile.with_name(self.lfile.name + ".remote")
            self.rclone.from_remote(self.rfile, cfile)
            self.ui.info_copyable("Remote file has been saved as:", cfile)
            logging.info("restarting due to manual conflict resolution")
            exit(1)
        elif answer == 1:
            logging.info("user decided to use local file")
            self.upload()
        elif answer == 0:
            logging.info("user decided to use remte file")
            self.download()

    def sync(self):
        lmd5sum = hashlib.md5(self.lfile.read_bytes()).hexdigest()
        # check if local file has changed since last sync
        if self.meta.data["md5sum"] != lmd5sum:
            # check if remote file has also changed
            if self.meta.data["md5sum"] != self.rclone.md5sum(self.rfile):
                # both local and remote changed, resolve manually or overwrite
                # TODO: try to resolve conflict by modification time
                self._handle_conflict()
            else:
                logging.warning("local file has changed since last upload")
                self.upload()
        elif self.meta.data["md5sum"] != self.rclone.md5sum(self.rfile):
            # remote file changed, download it
            logging.info("remote file has been updated")
            self.download()
        else:
            logging.info("remote and local file are the same")

    def download(self):
        self.rclone.from_remote(self.rfile, self.lfile)
        self.meta.data["mtime"] = str(self.rclone.mtime(self.rfile))
        self.meta.data["md5sum"] = self.rclone.md5sum(self.rfile)
        self.meta.store()
        self.ui.info("Sync", f"{self.lfile} has been downloaded")
        logging.info("file: '%s' downloaded", self.rfile)

    def upload(self):
        self.rclone.copyto(self.lfile, self.rfile)
        self.meta.data["mtime"] = str(self.rclone.mtime(self.rfile))
        self.meta.data["md5sum"] = self.rclone.md5sum(self.rfile)
        self.meta.store()
        self.ui.info("Sync", f"{self.lfile} has been uploaded")
        logging.info("file: '%s' uploaded to remote", self.rfile)


# meta_file = Path(XDG_DATA_HOME / "the_bundle.kdbx").resolve()


def main():
    db_file = Path(Path.home() / "SynologyDrive" / "the_bundle.kdbx").resolve()
    meta_file = Path(XDG_DATA_HOME / "dbfile.json").resolve()
    r_disk = "secret-share"
    rclone_password = None

    with closing(secretstorage.dbus_init()) as dbus:
        while True:
            collection = secretstorage.get_default_collection(dbus)
            if collection.is_locked():
                logging.info("secret storage still locked")
                time.sleep(1)
            items = list(collection.search_items({"Title": "RCloneConfig"}))
            if not items:
                logging.error("RCloneConfig secret not found")
                return 1
            item = items[0]
            if item.is_locked():
                item.unlock()
                while item.is_locked():
                    time.sleep(0.5)

            rclone_password = item.get_secret()
            logging.info("rclone credentials obtained")
            break

    rclone = RClone(r_disk, rclone_password)
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
