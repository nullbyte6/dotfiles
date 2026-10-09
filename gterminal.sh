#!/usr/bin/env bash
gsettings set org.gnome.desktop.default-applications.terminal exec $1
echo "Default terminal changed to $1"
