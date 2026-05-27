#!/usr/bin/env bash
# Render the GY-BME280 model to STL and refresh PNG previews.
# Re-run after editing gy_bme280.scad.

set -euo pipefail
cd "$(dirname "$0")"

mkdir -p stl previews

SRC="gy_bme280.scad"
CX=6.0    # pcb_x / 2
CY=7.5    # pcb_y / 2

openscad -o stl/gy_bme280.stl "$SRC"
echo "Exported stl/gy_bme280.stl"

openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera="$CX",$CY,25,0,0,0,90 \
  -o previews/bme280_top.png \
  "$SRC"
echo "Exported previews/bme280_top.png"

openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera="$CX",$CY,10,55,0,25,120 \
  -o previews/bme280_iso.png \
  "$SRC"
echo "Exported previews/bme280_iso.png"

openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,500 \
  --camera="$CX",$CY,2,90,0,0,90 \
  -o previews/bme280_side.png \
  "$SRC"
echo "Exported previews/bme280_side.png"
