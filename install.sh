#!/usr/bin/env sh

set -eu

APT_PACKAGES=" \
	shellcheck \
	tmux \
	vim \
"

install_apt()
{
	sudo /bin/sh -c "apt update && apt install --yes ${APT_PACKAGES}"
}

install_vim()
{
	ln -s "${PWD}/vim" "${HOME}/.vim"
}

install_tmux()
{
	install --backup --mode 0644 -T "${PWD}/tmux.conf" "${HOME}/.tmux.conf"
}

main()
{
#	install_apt
	install_vim
	install_tmux
}

main "${@}"
