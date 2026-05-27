# Case — 3D board models (OpenSCAD)

## ESP32 DevKit (38-pin, USB-C)

Detailed visualization model of an ESP32 38-pin development board with a USB-C
connector. Useful as a placeholder in enclosure designs, renders, and
breadboard mock-ups.

Reference dimensions: **55.3 × 28.0 × 1.6 mm** PCB.

## Files

| File | Description |
|------|-------------|
| `esp32_devkit_38pin.scad` | Parametric OpenSCAD source |
| `export.sh` | Renders the STL **and** the PNG previews |
| `stl/esp32_devkit_38pin.stl` | Generated mesh |
| `previews/top.png` | Top-down view of the assembled board |
| `previews/iso.png` | Isometric 3D view |
| `previews/side.png` | Side profile (pins pointing down) |

## Modeled features

- Black PCB 55.3 × 28.0 × 1.6 mm with rounded corners (no mounting holes)
- 38 square header pins (19 per side, 2.54 mm pitch) evenly spanning the full
  board length, with black plastic strips and gold pins above and below the PCB
- ESP32-WROOM-32 module placed on the antenna end:
  - Metal shield with embossed top and silkscreen label
  - 17 castellated copper pads on each long side and 6 on the USB-side short edge
  - Serpentine PCB antenna at the far end of the board
- USB-C jack (9 mm shell) protruding from the short edge, centered on the 28 mm width
- EN and IO0 tactile buttons flanking the USB-C connector
- AMS1117-3.3 LDO (SOT-223) with metal tab
- Tantalum / electrolytic capacitor (orange epoxy with polarity stripe)
- Red power LED and blue user LED with series resistors
- Decorative 1206 SMD passives near WROOM and regulator
- Centered silkscreen brand rectangle

## Render

```bash
./export.sh
```

This produces `stl/esp32_devkit_38pin.stl` and refreshes `previews/*.png`.

For interactive editing, open the `.scad` file in OpenSCAD (F5 = fast preview,
F6 = full CGAL render).

### How the previews are generated

OpenSCAD has a CLI mode that renders directly to PNG:

```bash
openscad \
  --colorscheme=Tomorrow \
  --imgsize=1400,900 \
  --camera=Tx,Ty,Tz,Rx,Ry,Rz,D \
  -o previews/<name>.png \
  esp32_devkit_38pin.scad
```

`--camera` takes a target point (`Tx,Ty,Tz`), rotations in degrees
(`Rx,Ry,Rz`) and a camera distance (`D`). The three rotations applied in
`export.sh` are:

| Preview | Rx | Ry | Rz | D | Notes |
|---------|----|----|----|---|-------|
| `top` | 0 | 0 | 0 | 90 | Camera straight down |
| `iso` | 55 | 0 | 30 | 180 | Tilted + rotated for 3D feel |
| `side` | 90 | 0 | 0 | 90 | Camera horizontal, looking at long edge |

Edit `export.sh` if you want to add or tweak views.

---

## GY-BME280 breakout

Detailed model of the purple GY-BME280 module (**12.0 × 15.0 × 1.6 mm**, width × length per dimension drawing).

| File | Description |
|------|-------------|
| `gy_bme280.scad` | Parametric source |
| `export_bme280.sh` | STL + previews |
| `stl/gy_bme280.stl` | Exported mesh |
| `previews/bme280_top.png` | Top view |
| `previews/bme280_iso.png` | Isometric view |
| `previews/bme280_side.png` | Side view |

### Modeled features

- Purple PCB 12.0 × 15.0 mm with rounded corners
- 6 through-holes on the left 15 mm edge (pitch 2.54 mm, centered), with 1×6 header and pins
- Two mounting holes (Ø 3 mm) on the right 15 mm edge, aligned with 1st and 6th pin
- Row of 4 resistors + 1 cap → BME280 sensor → bottom capacitor (layout from reference photo)
- BME280 metal-cap package with vent
- SMD resistors (1206), capacitors, small IC
- Simplified silkscreen blocks

```bash
./export_bme280.sh
```

## Notes

- Origin is at the lower-left corner of the PCB. Z = 0 is the bottom of the PCB;
  pins protrude downward (negative Z).
- Colours are for OpenSCAD preview only — STL files do not preserve them.
- Tweak the parameter block at the top of the `.scad` file to match the exact
  dimensions of your specific board variant if needed.
