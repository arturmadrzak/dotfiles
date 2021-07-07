#!/usr/bin/env sh

set -eu

APT_PACKAGES=" \
	shellcheck \
	tmux \
	vim \
    vim-gtk3 \
"

install_apt()
{
	sudo /bin/sh -c "apt update && apt install --yes ${APT_PACKAGES}"
}

install_vim()
{
    _vimdir="${HOME}/.vim"
    if [ -e "${_vimdir}" ]; then
        echo "Warning: Backuping '${_vimdir}' to '${_vimdir}.bak'"
        mv -T "${_vimdir}" "${_vimdir}.bak"
    fi
	ln -sT "${PWD}/vim" "${_vimdir}"
}

install_tmux()
{
    _tmuxconf="${HOME}/.tmux.conf"
    if [ -e "${_tmuxconf}" ]; then
        echo "Warning: Backuping '${_tmuxconf}' to '${_tmuxconf}.bak'"
        mv "${_tmuxconf}" "${_tmuxconf}.bak"
    fi
    ln -sT "${PWD}/tmux.conf" "${_tmuxconf}"
}

install_fuzzy_completer()
{
    cd fzf && ./install --all
}

main()
{
	install_apt
	install_vim
	install_tmux
    install_fuzzy_completer
}

main "${@}"
