#!/usr/bin/env bash
# Render weather station enclosure STLs and preview PNGs.
# Re-run after editing weatherstation_enclosure.scad.

set -euo pipefail
cd "$(dirname "$0")"

mkdir -p stl previews

SRC="weatherstation_enclosure.scad"
CX=30.0
CY=24.0
CZ=14.0

openscad -D'export_part="bottom"' -D'show_assembly=false' -D'show_boards=false' \
  -o stl/enclosure_bottom.stl "$SRC"
echo "Exported stl/enclosure_bottom.stl"

openscad -D'export_part="top_shell"' -D'show_assembly=false' -D'show_boards=false' \
  -o stl/enclosure_top.stl "$SRC"
echo "Exported stl/enclosure_top.stl (shell — assign body colour in slicer)"

openscad -D'export_part="top_logo"' -D'show_assembly=false' -D'show_boards=false' \
  -o stl/enclosure_top_logo.stl "$SRC"
echo "Exported stl/enclosure_top_logo.stl (white logo — assign white filament)"

openscad --export-format=3mf -D'export_part="top"' -D'show_assembly=false' -D'show_boards=false' \
  -o stl/enclosure_top.3mf "$SRC"
echo "Exported stl/enclosure_top.3mf (shell + white logo with colours)"

openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera="$CX",$CY,$CZ,55,0,25,220 \
  -D'show_assembly=true' -D'show_boards=true' -D'show_top=true' -D'export_part="assembly"' \
  -o previews/enclosure_iso.png \
  "$SRC"
echo "Exported previews/enclosure_iso.png"

openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera="$CX",$CY,$CZ,0,0,0,120 \
  -D'show_assembly=true' -D'show_boards=true' -D'show_top=true' -D'export_part="assembly"' \
  -o previews/enclosure_front.png \
  "$SRC"
echo "Exported previews/enclosure_front.png"

openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,500 \
  --camera="$CX",$CY,2,90,0,0,120 \
  -D'show_assembly=true' -D'show_boards=true' -D'show_top=true' -D'export_part="assembly"' \
  -o previews/enclosure_side.png \
  "$SRC"
echo "Exported previews/enclosure_side.png"
