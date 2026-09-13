#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if (( $# > 0 )); then
    folder=$1
else
    folder=$(kdialog --getexistingdirectory "$HOME" --title "Choose folder") || exit 0
fi

if [[ -z "$folder" || ! -d "$folder" ]]; then
    kdialog --error "The selected folder is not valid:\n$folder"
    exit 1
fi

password=$(kdialog --password "Enter your sudo password" --title "Authentication") || exit 0
user=$(id -un)

run_sudo() {
    printf '%s\n' "$password" | sudo -S -p '' -- "$@"
}

if ! run_sudo chown -R "$user:$user" -- "$folder" || \
    ! run_sudo chmod -R 755 -- "$folder"; then
    kdialog --error "Could not update permissions for:\n$folder"
    exit 1
fi

unset password
kdialog --msgbox "Ownership and permissions updated for:\n$folder" --title "Take Ownership"
