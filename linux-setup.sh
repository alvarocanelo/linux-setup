#!/usr/bin/env bash

solve_conflict(){
    f="$1"
    if [ -e "/$f" ] ; then
        # Ask if check differences
        echo
        echo "File /$f already exists."
        while true ; do
            q="Do you want to check differences for this file? [Y/n]: "
            read -p "$q" yn
            case $yn in
                [Yy]*)
                    diff "/$f" "$(dirname $0)/$f"
                    break ;;
                [Nn]*)
                    break ;;
            esac
        done
        while true ; do
            q="Do you want to overwrite it or skip it? [Y/n]: "
            read -p "$q" yn
            case $yn in
                [Yy]*)  break ;;
                [Nn]*)  return 1 ;;
            esac
        done
    fi
    return 0
}

set -e

# ### Linux packages
# # Add repositories signing keys to be able to verify downloaded packages
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
# # Add repositories
# echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
# # Update list of available packages
# printf "\nUpdating aptitude:\n"
# sudo aptitude update
# # Install packages
# packages="
# curl
# ipython
# radiotray
# screen
# skype
# spotify.client
# sshfs
# terminator
# tmux
# tree
# wget
# "
# printf "\nInstalling the following packages:\n\n"
# for p in $packages ; do echo "$p" ; done ; echo
# sudo aptitude install -y $packages

### Copy configuration files
directories="
home
"
current_dir="$(dirname $0)"
for d in $directories ; do
    for f in $(find $d -type f) ; do
        if solve_conflict "$f" ; then
            echo "Copying /$f"
            echo cp "$current_dir"/"$f" /"$f"
        fi
    done
done
