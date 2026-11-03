# shellcheck disable=SC2155

# This file is sourced by user's .bashrc file. It's intended to define aliases, although
# also hacked to set up misc things, to avoid altering/parsing bashrc directly
alias hadolint='docker run --rm -i hadolint/hadolint'
alias rgl="rg -l"
alias rmorig="find . -type f -name '*.orig' -print -exec rm -f {} +"
alias wakenuc="wakeonlan 88:AE:DD:07:6B:A9"
alias wakeryzen="wakeonlan 18:c0:4d:9c:41:97"
alias yamlint='docker run -it --rm -v "${PWD}:/workdir" ghcr.io/ffurrer2/yamllint:latest'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

export DEBEMAIL="artur@madrzak.eu"
export DEBFULLNAME="Artur Mądrzak"
export DOCKER_BUILDKIT=1
export FZF_DEFAULT_OPTS='--tmux bottom'
export HISTFILESIZE=20000
export HISTSIZE=10000
export PYLINT_VENV_PATH=venv:.venv:venv2:.virtualenv

if [ -z "${SSH_TTY:-}" ] && command -v secret-tool >/dev/null 2>&1; then
    export OPENAI_API_KEY="$(secret-tool lookup Title openai-cli-token)"
    export RCLONE_CONFIG_PASS="$(secret-tool lookup Title RCloneConfig)"
else
    echo "WARNING: secret-tool not found"
fi

if [ -n "$DISTROBOX_ENTER_PATH" ]; then
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"

    PS1='\[\e]0;\u@distrobox('"$codename"'): \w\a\]'
    PS1+='${debian_chroot:+($debian_chroot)}'
    PS1+='\[\e[1;38;5;208m\]\u@distrobox('"$codename"')\[\e[0m\]:'
    PS1+='\[\e[1;38;5;141m\]\w\[\e[0m\]\$ '
fi

gh() {
    local dir home

    dir="$(pwd -P)"
    home="$(cd "$HOME" && pwd -P)"

    # Only walk directories below $HOME.
    case "$dir/" in
        "$home/"*) ;;
        *)
            command gh "$@"
            return
            ;;
    esac

    while true; do
        if [[ -d "$dir/.config/gh" ]]; then
            GH_CONFIG_DIR="$dir/.config/gh" command gh "$@"
            return
        fi

        [[ "$dir" == "$home" ]] && break
        dir="${dir%/*}"
    done

    command gh "$@"
}

# vim: ft=sh
