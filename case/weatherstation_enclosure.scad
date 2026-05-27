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

// Snap-fit — top shell clips onto floor tray lip
snap_tab_w       = 7.0;
snap_flex_t      = 1.1;
snap_hook_depth  = 0.75;
snap_inset       = 12.0;
floor_lip_h      = 0.85;   // retention ring on base top edge
floor_lip_inset  = 1.1;    // lip width on floor perimeter

// Lid emboss — branding on top face (white — separate filament / 3MF colour)
lid_emboss_h     = 0.5;
lid_font         = "Liberation Sans:style=Bold";
lid_font_light   = "Liberation Sans:style=Regular";
lid_logo_color   = [1, 1, 1];

// Preview / export
show_assembly = true;
show_boards   = true;
show_top      = true;
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

// Perimeter lip on floor tray — hooks on top shell snap under this ring
module floor_retention_lip() {
  difference() {
    translate([0, 0, floor - 0.01])
      rounded_block(case_l, case_w, floor_lip_h, corner_r);
    translate([floor_lip_inset, floor_lip_inset, floor - 0.02])
      rounded_block(
        case_l - 2 * floor_lip_inset,
        case_w - 2 * floor_lip_inset,
        floor_lip_h + 0.1,
        max(corner_r - floor_lip_inset, 1.0)
      );
  }
}

// Finger notch on back wall to pry the top shell open
module lid_release_notch() {
  nw = 14.0;
  nh = 1.4;
  translate([case_l / 2 - nw / 2, -0.5, floor - 0.2])
    cube([nw, wall + 1.2, nh + floor_lip_h + 0.4]);
}

// Cantilever clip at bottom of top shell — hooks under floor lip
module snap_clip_x(y_center, positive_x) {
  dir = positive_x ? 1 : -1;
  x0  = positive_x ? (case_l - wall - snap_flex_t) : wall;
  clip_h = floor_lip_h + 1.1;

  translate([x0, y_center - snap_tab_w / 2, floor - 0.4])
    union() {
      cube([snap_flex_t, snap_tab_w, clip_h]);
      translate([dir * snap_flex_t, 0, 0.15])
        cube([dir * (snap_hook_depth + 0.35), snap_tab_w, 0.95]);
      translate([dir * snap_flex_t, 0, 0.85])
        cube([dir * (snap_hook_depth + 0.55), snap_tab_w, 0.55]);
    }
}

module snap_clip_y(x_center, positive_y) {
  dir = positive_y ? 1 : -1;
  y0  = positive_y ? (case_w - wall - snap_flex_t) : wall;
  clip_h = floor_lip_h + 1.1;

  translate([x_center - snap_tab_w / 2, y0, floor - 0.4])
    union() {
      cube([snap_tab_w, snap_flex_t, clip_h]);
      translate([0, dir * snap_flex_t, 0.15])
        cube([snap_tab_w, dir * (snap_hook_depth + 0.35), 0.95]);
      translate([0, dir * snap_flex_t, 0.85])
        cube([snap_tab_w, dir * (snap_hook_depth + 0.55), 0.55]);
    }
}

module snap_clips_top() {
  for (cy = [snap_inset, case_w - snap_inset])
    snap_clip_x(cy, true);
  for (cx = [snap_inset + 8, case_l - snap_inset])
    snap_clip_y(cx, false);
}

// ---------------------------------------------------------------------
// Lid emboss — weather icons + product label
// ---------------------------------------------------------------------

// Single merged weather emblem — sun behind cloud + rain
module weather_icon_merged_2d(s = 1) {
  union() {
    // Sun (upper left, partially hidden by cloud)
    translate([-3.8 * s, 3.2 * s]) {
      circle(r = 2.35 * s, $fn = 36);
      for (a = [0 : 45 : 315])
        rotate(a)
          translate([0, 3.2 * s])
            square([0.45 * s, 1.15 * s], center = true);
    }

    // Cloud (foreground — overlaps sun for one silhouette)
    hull() {
      translate([-2.6 * s, 0.4 * s]) circle(r = 2.0 * s, $fn = 28);
      translate([0.5 * s, 1.5 * s]) circle(r = 2.35 * s, $fn = 28);
      translate([3.0 * s, 0.5 * s]) circle(r = 1.85 * s, $fn = 28);
    }

    // Rain drops under cloud
    for (dx = [-1.9, -0.65, 0.65, 1.9])
      translate([dx * s, -2.6 * s])
        scale([0.65, 1.15])
          circle(r = 0.72 * s, $fn = 18);
  }
}

module lid_emboss_extrude_2d() {
  linear_extrude(lid_emboss_h)
    children(0);
}

module lid_emboss_text(str, size, font) {
  lid_emboss_extrude_2d()
    offset(delta = 0.08, $fn = 12)
      text(str, size = size, halign = "center", valign = "center", font = font);
}

module lid_emboss_decor() {
  cx = case_l / 2;
  cy = case_w / 2;
  z0 = case_h - 0.01;

  intersection() {
    translate([0, 0, body_top_z - 0.01])
      cube([case_l, case_w, lid_plate_h + lid_emboss_h + 0.02]);

    union() {
      translate([cx, cy + 9.75, z0])
        lid_emboss_extrude_2d()
          offset(delta = 0.06, $fn = 10)
            weather_icon_merged_2d(1.23);

      translate([cx, cy - 1.8, z0])
        lid_emboss_text("Weather Station", 3.9, lid_font);

      translate([cx, cy - 7.8, z0])
        lid_emboss_text("v1.0", 3.0, lid_font_light);
    }
  }
}

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
      union() {
        rounded_block(case_l, case_w, floor, corner_r);
        floor_retention_lip();
      }

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
// Top — walls + flat lid (shell) + white logo insert
// =====================================================================

module enclosure_top_shell() {
  shell_h = case_h - floor;

  color(case_gray_light)
    difference() {
      union() {
        translate([0, 0, floor])
          rounded_block(case_l, case_w, shell_h, corner_r);
        snap_clips_top();
      }

      inner_cavity(case_l, case_w, body_top_z - floor + 0.01, floor, corner_r);

      vent_grille_cut_y(vent_face_y, vent_cx, vent_cz, vent_w, vent_h);
      usb_cut();
      lid_release_notch();
    }
}

module enclosure_top_logo() {
  color(lid_logo_color)
    lid_emboss_decor();
}

module enclosure_top() {
  union() {
    enclosure_top_shell();
    enclosure_top_logo();
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
else if (export_part == "top_shell")
  enclosure_top_shell();
else if (export_part == "top_logo")
  enclosure_top_logo();
else if (export_part == "top")
  enclosure_top();
else if (show_assembly)
  full_assembly();
else
  enclosure_bottom_with_feet();
