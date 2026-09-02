#!/bin/bash
# Installs every theme (both formats) into Xcode's user theme folder.
set -euo pipefail
DEST="$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
mkdir -p "$DEST"
n=0
for f in "$(dirname "$0")"/themes/*.xccolortheme "$(dirname "$0")"/themes/*.xcworkspacecolortheme; do
  cp "$f" "$DEST/" && n=$((n+1))
done
echo "Installed $n theme files into $DEST — restart Xcode to see them."
