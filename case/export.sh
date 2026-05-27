#!/usr/bin/env bash
# Render the ESP32 model to STL and refresh the PNG previews.
# Re-run after editing esp32_devkit_38pin.scad.

set -euo pipefail
cd "$(dirname "$0")"

mkdir -p stl previews

SRC="esp32_devkit_38pin.scad"

# Center of the PCB (matches pcb_l/2 and pcb_w/2 in the .scad)
CX=27.65
CY=14

# Mesh export (geometry-only; STL has no colors)
openscad -o stl/esp32_devkit_38pin.stl "$SRC"
echo "Exported stl/esp32_devkit_38pin.stl"

# Top-down view (great for verifying component layout)
openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera="$CX",$CY,30,0,0,0,90 \
  -o previews/top.png \
  "$SRC"
echo "Exported previews/top.png"

# Isometric view (3D feel)
openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera="$CX",$CY,15,55,0,30,180 \
  -o previews/iso.png \
  "$SRC"
echo "Exported previews/iso.png"

# Side view (long edge, pins pointing down)
openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,500 \
  --camera="$CX",$CY,2,90,0,0,90 \
  -o previews/side.png \
  "$SRC"
echo "Exported previews/side.png"
