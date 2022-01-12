#! /usr/bin/env sh

SCRIPT_DIRECTORY="$(dirname -- "$(readlink -f -- "$0")")"
PROJECT_DIRECTORY="$(dirname -- "$SCRIPT_DIRECTORY")"

( # Create subshell to nullify directory changes on exit
    # Run makepkg
    set -o xtrace
    cd "$SCRIPT_DIRECTORY"/archlinux_packaging && \
    makepkg \
        --force \
        --syncdeps \
        "$@"
    set +o xtrace
)
