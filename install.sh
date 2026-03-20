#!/usr/bin/env bash

echo "installing grimoire..."

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/.config/$2"
  mkdir -p "$(dirname "$dst")"
  cp -r "$src" "$dst"
  echo " copied $1 -> $dst"
}

link "hypr"              "hypr"
link "waybar/config"     "waybar/config"
link "waybar/style.css"  "waybar/style.css"
link "kitty/kitty.conf"  "kitty/kitty.conf"
link "wofi/style.css"    "wofi/style.css"
link "mako/config"       "mako/config"
link "fastfetch"         "fastfetch"
link "fish/config.fish"  "fish/config.fish"
link "yazi/theme.toml"   "yazi/theme.toml"

mkdir -p "$HOME/Pictures/wallpaper"
cp -r "$DOTFILES/wallpaper/." "$HOME/Pictures/wallpaper/"
echo " copied wallpaper -> ~/Pictures/wallpaper"

echo "done. reload hyprland with: hyprctl reload"
