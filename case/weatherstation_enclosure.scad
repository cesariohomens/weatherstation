// Weather station enclosure — indie consumer-electronics aesthetic
// Fits ESP32 DevKit 38-pin + GY-BME280 breakout
//
// Base = floor tray + standoffs. Top = walls + flat lid only.
//
// Export: ./export_enclosure.sh
// Preview: F5 / F6 in OpenSCAD

ENCLOSURE_BUILD = true;
include <esp32_devkit_38pin.scad>
include <gy_bme280.scad>

$fn = 48;

// =====================================================================
// Enclosure parameters (mm)
// =====================================================================

wall          = 2.4;
floor         = 2.5;
corner_r      = 4.0;
board_gap     = 3.0;

// case_l = comprimento (X)
case_l = 64.0;

// case_w = largura (Y) — ESP32 + folga + BME280 + folga frontal
bme_front_clearance = 2.0;
case_w = wall + esp32_pcb_w + board_gap + bme_pcb_h + bme_front_clearance + wall;   // 49.8 mm
case_h        = 24.0;

// Lid — smooth flat plate on top shell
lid_plate_h = wall;
body_top_z  = case_h - lid_plate_h;

// Board placement (origin = bottom-left-back corner, z = 0 is bottom of floor tray)
esp_x = wall;
esp_y = wall;
esp_z = floor + hdr_pin_dn;

bme_x      = wall + (case_l - 2 * wall - bme_pcb_w) / 2;
bme_y      = esp_y + esp32_pcb_w + board_gap;
bme_z      = 9.0;
bme_rotate = 180;

// USB cutout (left wall of top shell)
usb_open_w = usbc_shell_w + 1.6;
usb_open_h = usbc_height + 1.4;
usb_open_y = esp_y + usbc_cy;
usb_open_z = esp_z + pcb_t + usbc_height / 2;

// Ranhuras na parede frontal (+Y), alinhadas com o BME280
vent_face_y = case_w;
vent_cx     = bme_x + bme_pcb_w / 2;
vent_cz     = bme_z + bme_pcb_t + 2.0;
vent_w      = 12.0;
vent_h      = 8.0;
vent_slot_w = 0.85;
vent_count  = 5;

// BME280 standoffs (align with mount_x / mount_y in gy_bme280.scad)
bme_standoff_od  = 4.8;
bme_screw_hole_d = 2.2;   // M2 tap / clearance in plastic

// ESP32 corner-pin standoffs (1st + 19th pin on each header row)
esp_standoff_od = 4.0;
esp_pin_hole_d  = 0.85;   // hdr_pin_t = 0.64 mm square

// Preview / export
show_assembly = true;
show_boards   = true;
show_top      = false;
export_part   = "assembly";

case_gray_dark  = [0.34, 0.35, 0.37];
case_gray_mid   = [0.46, 0.47, 0.49];
case_gray_light = [0.58, 0.59, 0.61];

// =====================================================================
// Helpers
// =====================================================================

module rounded_block(l, w, h, r) {
  hull() {
    for (x = [r, l - r])
      for (y = [r, w - r])
        translate([x, y, 0])
          cylinder(r = r, h = h);
  }
}

// Interior void — open tub (no floor), used by top shell
module inner_cavity(l, w, h, z0, r) {
  translate([wall, wall, z0])
    rounded_block(l - 2 * wall, w - 2 * wall, h, max(r - wall, 1.0));
}

module vent_grille_cut_y(y_face, cx, cz, width, height) {
  pitch = height / (vent_count + 1);
  for (i = [1 : vent_count])
    translate([cx - width / 2, y_face - wall - 0.5, cz - height / 2 + i * pitch - vent_slot_w / 2])
      cube([width, wall + 1.5, vent_slot_w]);
}

module usb_cut() {
  translate([-0.5, usb_open_y - usb_open_w / 2, usb_open_z - usb_open_h / 2])
    cube([wall + 1, usb_open_w, usb_open_h]);
  translate([wall - 0.8, usb_open_y - usb_open_w / 2 - 1.2, usb_open_z - usb_open_h / 2 - 1.0])
    cube([1.6, usb_open_w + 2.4, usb_open_h + 2.0]);
}

// Standoffs rise from floor (part of base)
module bme_mount_standoff_at(lx, ly) {
  standoff_h = bme_z - floor;
  difference() {
    translate([lx, ly, floor])
      cylinder(d = bme_standoff_od, h = standoff_h);
    translate([lx, ly, floor - 0.5])
      cylinder(d = bme_screw_hole_d, h = standoff_h + 1);
  }
}

module bme_mount_standoffs() {
  color(case_gray_mid)
    translate([bme_x + bme_pcb_w / 2, bme_y + bme_pcb_h / 2, 0])
      rotate([0, 0, bme_rotate])
        translate([-bme_pcb_w / 2, -bme_pcb_h / 2, 0])
          for (hole = [[mount_x, mount_y], [bme_pcb_w - mount_x, mount_y]])
            bme_mount_standoff_at(hole[0], hole[1]);
}

module esp_pin_standoff_at(lx, ly) {
  standoff_h = esp_z - floor;
  difference() {
    translate([esp_x + lx, esp_y + ly, floor])
      cylinder(d = esp_standoff_od, h = standoff_h);
    translate([esp_x + lx, esp_y + ly, floor - 0.5])
      cylinder(d = esp_pin_hole_d, h = standoff_h + 0.5);
  }
}

module esp_pin_standoffs() {
  color(case_gray_mid)
    for (ly = [hdr_inset_y, esp32_pcb_w - hdr_inset_y])
      for (lx = [hdr_x0, hdr_x0 + hdr_span])
        esp_pin_standoff_at(lx, ly);
}

// =====================================================================
// Bottom — floor tray + standoffs (no walls)
// =====================================================================

module feet() {
  pad   = 4.0;
  inset = 6.0;
  color(case_gray_mid)
    for (dx = [inset, case_l - inset])
      for (dy = [inset, case_w - inset])
        translate([dx, dy, 0])
          cylinder(d = pad, h = 0.9);
}

module enclosure_bottom() {
  union() {
    color(case_gray_dark)
      rounded_block(case_l, case_w, floor, corner_r);

    bme_mount_standoffs();
    esp_pin_standoffs();
  }
}

module enclosure_bottom_with_feet() {
  union() {
    enclosure_bottom();
    feet();
  }
}

// =====================================================================
// Top — walls + flat lid only
// =====================================================================

module enclosure_top() {
  shell_h = case_h - floor;

  color(case_gray_light)
    difference() {
      translate([0, 0, floor])
        rounded_block(case_l, case_w, shell_h, corner_r);

      inner_cavity(case_l, case_w, body_top_z - floor + 0.01, floor, corner_r);

      vent_grille_cut_y(vent_face_y, vent_cx, vent_cz, vent_w, vent_h);
      usb_cut();
    }
}

// =====================================================================
// Boards
// =====================================================================

module board_preview() {
  if (show_boards) {
    translate([esp_x, esp_y, esp_z])
      esp32_devkit_38pin();

    translate([bme_x + bme_pcb_w / 2, bme_y + bme_pcb_h / 2, bme_z])
      rotate([0, 0, bme_rotate])
        translate([-bme_pcb_w / 2, -bme_pcb_h / 2, 0])
          gy_bme280();
  }
}

module full_assembly() {
  enclosure_bottom_with_feet();
  if (show_top)
    enclosure_top();
  board_preview();
}

// =====================================================================
// Render
// =====================================================================

if (export_part == "bottom")
  enclosure_bottom_with_feet();
else if (export_part == "top")
  enclosure_top();
else if (show_assembly)
  full_assembly();
else
  enclosure_bottom_with_feet();
