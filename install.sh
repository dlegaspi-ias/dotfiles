#!/usr/bin/env bash
#
# install.sh — symlink this repo's configs into place.
#
# Safe to re-run. Existing real files (not already symlinks into this repo)
# are backed up with a .bak-<timestamp> suffix before being replaced.
#
# Usage:
#   ./install.sh          # symlink everything
#   ./install.sh nvim     # symlink just one target (nvim, tmux, zellij, starship)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok      $dest -> $src"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak-$STAMP"
    echo "backed up existing $dest -> $dest.bak-$STAMP"
  fi
  ln -s "$src" "$dest"
  echo "linked  $dest -> $src"
}

target="${1:-all}"

if [ "$target" = "all" ] || [ "$target" = "nvim" ]; then
  link "$REPO_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
fi

if [ "$target" = "all" ] || [ "$target" = "tmux" ]; then
  link "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

if [ "$target" = "all" ] || [ "$target" = "zellij" ]; then
  link "$REPO_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
fi

if [ "$target" = "all" ] || [ "$target" = "starship" ]; then
  link "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

echo "Done."
