#!/usr/bin/env bash

set -e

# Linux packages

printf "\nUpdating aptitude:\n"
sudo aptitude update

packages="
curl
radiotray
screen
sshfs
terminator
tmux
tree
wget
"
printf "\nInstalling the following packages:\n\n"
for p in $packages ; do echo "$p" ; done ; echo

sudo aptitude install -y terminator
