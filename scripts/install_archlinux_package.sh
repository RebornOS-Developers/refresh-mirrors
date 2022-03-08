#! /usr/bin/env sh

SCRIPT_DIRECTORY="$(dirname -- "$(readlink -f -- "$0")")"
PROJECT_DIRECTORY="$(dirname -- "$SCRIPT_DIRECTORY")"

if ls "$SCRIPT_DIRECTORY"/*.pkg.tar.* > /dev/null 2>&1;then
    set -o xtrace
    sudo pacman -U "$@" "$SCRIPT_DIRECTORY"/archlinux_packaging/*.pkg.tar.zst
    set +o xtrace
else
    set -o xtrace
    sh "$SCRIPT_DIRECTORY"/build_archlinux_package.sh --install "$@"
    set +o xtrace
fi
