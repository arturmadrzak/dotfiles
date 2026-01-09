# shellcheck disable=SC2155

# This file is sourced by user's .bashrc file. It's intended to define aliases, although
# also hacked to set up misc things, to avoid altering/parsing bashrc directly
alias hadolint='docker run --rm -i hadolint/hadolint'
alias rgl="rg -l"
alias rmorig="find . -type f -name '*.orig' -print -exec rm -f {} +"
alias wakenuc="wakeonlan 88:AE:DD:07:6B:A9"
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
export OPENAI_API_KEY="$(secret-tool lookup Title openai-cli-token)"
export PYLINT_VENV_PATH=venv:.venv:venv2:.virtualenv
export RCLONE_CONFIG_PASS="$(secret-tool lookup Title RCloneConfig)"

# vim: ft=sh
