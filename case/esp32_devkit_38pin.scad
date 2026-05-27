// ESP32 DevKit 38-pin (USB-C variant) — detailed visualization model
// Reference: 55.3 mm × 28.0 mm board, USB-C on the short edge,
//            WROOM-32 on the opposite end, EN + IO0 buttons flanking USB-C
// Preview: open in OpenSCAD (F5 = preview, F6 = render)
// Export STL: ./export.sh

$fn = 36;

// =====================================================================
// Parameters (mm)
// =====================================================================

// PCB
pcb_l       = 55.3;
pcb_w       = 28.0;
pcb_t       = 1.6;
pcb_r       = 1.5;
pcb_color   = "#1c1c1c";

// Headers (2.54 mm pitch, 19 pins each side — full length of the board)
hdr_n       = 19;
hdr_pitch   = 2.54;
hdr_span    = (hdr_n - 1) * hdr_pitch;   // 45.72 mm between first and last pin
hdr_x0      = (pcb_l - hdr_span) / 2;    // centered: equal margin at USB and antenna ends
hdr_inset_y = 1.27;
hdr_strip_h = 2.54;
hdr_strip_w = 2.54;
hdr_pin_up  = 2.6;
hdr_pin_dn  = 6.0;
hdr_pin_t   = 0.64;
pin_color   = "Goldenrod";
plastic_blk = "#1a1a1a";
silk_color  = "White";

// ESP32-WROOM-32 module — long axis along board's X, antenna at the far end
wroom_long      = 25.5;       // module length (X on the board)
wroom_short     = 18.0;       // module width (Y on the board)
wroom_pcb_t     = 0.8;
wroom_shield_l  = 17.5;       // shield length along X (rest is antenna PCB)
wroom_shield_h  = 2.4;
wroom_x         = pcb_l - wroom_long - 0.6;   // antenna at far end of board
wroom_y         = (pcb_w - wroom_short) / 2;
shield_color    = "Silver";
wroom_pad_pitch = 1.5;        // exposed castellated pad pitch
wroom_pad_w     = 0.8;        // pad width (along X)
wroom_pad_l     = 1.2;        // pad protruding past shield (along Y)

// USB-C jack (flush with x = 0 board edge, centered on width)
usbc_shell_w  = 9.0;          // shell width (Y)
usbc_depth    = 5.5;          // depth into board (+X), shorter housing
usbc_height   = 2.6;          // height above PCB
usbc_corner_r = 0.5;          // corner radius (minkowski)
usbc_cy       = pcb_w / 2;                // USB centered on board width
usbc_y        = usbc_cy - usbc_shell_w / 2;

// Tactile buttons (EN / IO0) — 3.5 mm SMD tact footprint
btn_s         = 3.6;
btn_h         = 2.0;
btn_cap       = 2.0;
btn_cap_h     = 0.6;
btn_usb_gap   = 1.2;          // clearance USB shell edge → nearest button face (both sides)
btn_x         = (usbc_depth + 2 * usbc_corner_r) / 2 - btn_s / 2;  // centered on USB depth

// AMS1117-3.3 LDO (SOT-223)
ams_l = 6.5;
ams_w = 3.5;
ams_t = 1.6;

// Tantalum / electrolytic cap (orange)
cap_l = 6.0;
cap_w = 3.2;
cap_t = 1.8;

// SMD passives 1206 / LEDs 0805
r1206   = [3.2, 1.6, 0.55];
led0805 = [2.0, 1.25, 0.6];

// =====================================================================
// Helpers
// =====================================================================

module rounded_plate(l, w, t, r) {
  hull() {
    for (x = [r, l - r])
      for (y = [r, w - r])
        translate([x, y, 0])
          cylinder(r = r, h = t);
  }
}

module pad_ring(d_outer, d_inner, h = 0.06) {
  difference() {
    cylinder(d = d_outer, h = h);
    translate([0, 0, -0.05])
      cylinder(d = d_inner, h = h + 0.1);
  }
}

// =====================================================================
// PCB
// =====================================================================

module pcb() {
  color(pcb_color)
    rounded_plate(pcb_l, pcb_w, pcb_t, pcb_r);

  // header pad rings (top side)
  color(pin_color)
    for (i = [0 : hdr_n - 1]) {
      translate([hdr_x0 + i * hdr_pitch, hdr_inset_y, pcb_t - 0.04])
        pad_ring(2.0, hdr_pin_t * 2.0);
      translate([hdr_x0 + i * hdr_pitch, pcb_w - hdr_inset_y, pcb_t - 0.04])
        pad_ring(2.0, hdr_pin_t * 2.0);
    }
}

// =====================================================================
// Pin headers
// =====================================================================

module pin_one() {
  color(pin_color)
    translate([-hdr_pin_t / 2, -hdr_pin_t / 2, -hdr_pin_dn])
      cube([hdr_pin_t, hdr_pin_t,
            hdr_pin_dn + pcb_t + hdr_strip_h + hdr_pin_up]);
}

module header_strip(n) {
  color(plastic_blk)
    translate([0, -hdr_strip_w / 2, pcb_t])
      cube([n * hdr_pitch, hdr_strip_w, hdr_strip_h]);
}

module pin_row(n, x0, y) {
  translate([x0 - hdr_pitch / 2, y, 0])
    header_strip(n);
  for (i = [0 : n - 1])
    translate([x0 + i * hdr_pitch, y, 0])
      pin_one();
}

// =====================================================================
// ESP32-WROOM-32 module
// =====================================================================

module wroom32() {
  // module PCB
  color("#0a0a0a")
    cube([wroom_long, wroom_short, wroom_pcb_t]);

  // shield over the IC end (leaves antenna PCB visible at +X end)
  color(shield_color)
    translate([0, 0, wroom_pcb_t])
      difference() {
        cube([wroom_shield_l, wroom_short, wroom_shield_h]);
        // shallow embossed rectangle on top
        translate([1.2, 1.2, wroom_shield_h - 0.15])
          cube([wroom_shield_l - 2.4, wroom_short - 2.4, 0.2]);
      }

  // exposed castellated pads along long sides (X) of the shield
  pads_n = 17;
  pads_span = (pads_n - 1) * wroom_pad_pitch;
  pad_x0 = (wroom_shield_l - pads_span) / 2 - wroom_pad_w / 2;
  color(pin_color) {
    for (i = [0 : pads_n - 1]) {
      translate([pad_x0 + i * wroom_pad_pitch, -wroom_pad_l + 0.2, wroom_pcb_t - 0.04])
        cube([wroom_pad_w, wroom_pad_l, 0.06]);
      translate([pad_x0 + i * wroom_pad_pitch, wroom_short - 0.2, wroom_pcb_t - 0.04])
        cube([wroom_pad_w, wroom_pad_l, 0.06]);
    }
    // pads on the short USB-side edge of the shield (6 pads)
    short_n = 6;
    short_pitch = 1.5;
    short_y0 = (wroom_short - (short_n - 1) * short_pitch) / 2 - wroom_pad_w / 2;
    for (i = [0 : short_n - 1])
      translate([-wroom_pad_l + 0.2, short_y0 + i * short_pitch, wroom_pcb_t - 0.04])
        cube([wroom_pad_l, wroom_pad_w, 0.06]);
  }

  antenna_meander();

  // FCC / silkscreen label rectangle on top of shield
  color(silk_color)
    translate([wroom_shield_l / 2 - 6, wroom_short / 2 - 1.0,
               wroom_pcb_t + wroom_shield_h])
      cube([12, 2, 0.05]);
}

module antenna_meander() {
  // Serpentine on the antenna PCB region (x > wroom_shield_l)
  trace = 0.55;
  th    = 0.07;
  z     = wroom_pcb_t + 0.01;
  m_x0  = wroom_shield_l + 1.0;
  m_x1  = wroom_long - 1.0;
  m_y0  = 1.5;
  m_y1  = wroom_short - 1.5;
  rows  = 4;
  row_pitch = (m_y1 - m_y0 - trace) / (rows - 1);
  color(pin_color) {
    for (i = [0 : rows - 1])
      translate([m_x0, m_y0 + i * row_pitch, z])
        cube([m_x1 - m_x0, trace, th]);
    for (i = [0 : rows - 2]) {
      x = (i % 2 == 0) ? m_x1 - trace : m_x0;
      translate([x, m_y0 + i * row_pitch, z])
        cube([trace, row_pitch + trace, th]);
    }
    // feed line into shield zone
    translate([wroom_shield_l - 1.5, wroom_short / 2 - trace / 2, z])
      cube([m_x0 - wroom_shield_l + 2.0, trace, th]);
  }
}

// =====================================================================
// USB-C jack
// =====================================================================

module usbc_jack() {
  // Shell flush with PCB edge (x = 0); outer face aligned to board limits in Y
  r = usbc_corner_r;
  color(shield_color)
    minkowski() {
      cube([usbc_depth - 2 * r, usbc_shell_w - 2 * r, usbc_height - 2 * r]);
      sphere(r = r, $fn = 16);
    }
}

// =====================================================================
// Components
// =====================================================================

module tact_button() {
  color(plastic_blk)
    cube([btn_s, btn_s, btn_h]);
  color("#bdbdbd")
    translate([btn_s / 2, btn_s / 2, btn_h])
      cylinder(d = btn_cap, h = btn_cap_h);
}

module ams1117() {
  color(plastic_blk)
    cube([ams_l, ams_w, ams_t]);
  // metal heat tab on the back
  color(shield_color)
    translate([1.0, ams_w, 0])
      cube([ams_l - 2.0, 1.4, 0.5]);
  // 3 small pins on the front
  for (i = [0, 1, 2])
    color(shield_color)
      translate([1.2 + i * 1.8, -1.2, 0])
        cube([0.6, 1.2, 0.5]);
}

module tantalum_cap() {
  // orange epoxy body with a darker stripe (polarity)
  color("#e07a1c")
    cube([cap_l, cap_w, cap_t]);
  color("#1a1a1a")
    translate([cap_l - 0.6, 0, 0])
      cube([0.6, cap_w, cap_t + 0.01]);
}

module smd_block(size, c) {
  color(c) cube(size);
}

// EN below USB (low Y), IO0 above USB (high Y) — mirrored spacing
module flank_button(is_en) {
  d = usbc_shell_w / 2 + btn_usb_gap;
  y = is_en ? (usbc_cy - d - btn_s) : (usbc_cy + d);
  translate([btn_x, y, pcb_t])
    tact_button();
}

// =====================================================================
// Assembly
// =====================================================================

module esp32_devkit_38pin() {
  pcb();

  // Headers
  pin_row(hdr_n, hdr_x0, hdr_inset_y);
  pin_row(hdr_n, hdr_x0, pcb_w - hdr_inset_y);

  // ESP32-WROOM-32 module
  translate([wroom_x, wroom_y, pcb_t])
    wroom32();

  // USB-C — back face at x = 0, centered on pcb_w
  translate([0, usbc_y, pcb_t])
    usbc_jack();

  // Buttons: equal gap to USB shell on both sides (same distance from USB center)
  flank_button(true);   // EN (reset)
  flank_button(false);  // IO0 (boot)

  // Power chain between USB-C and WROOM
  // AMS1117 (right of the cap)
  translate([18.0, 4.0, pcb_t])
    ams1117();
  // Tantalum cap (left of regulator)
  translate([10.0, 4.0, pcb_t])
    tantalum_cap();
  // Decoupling caps in front of regulator
  translate([18.0, pcb_w - 4.0 - r1206[1], pcb_t])
    smd_block(r1206, "#a06030");
  translate([22.5, pcb_w - 4.0 - r1206[1], pcb_t])
    smd_block(r1206, "#a06030");

  // Power LED (red) and user LED (blue) near WROOM, inside its row
  translate([12.0, 11.0, pcb_t]) smd_block(led0805, "Red");
  translate([15.5, 11.0, pcb_t]) smd_block(led0805, "Blue");
  // Series resistors next to LEDs
  translate([12.0, 14.0, pcb_t]) smd_block(r1206, "#202020");
  translate([15.5, 14.0, pcb_t]) smd_block(r1206, "#202020");

  // Pull-up / decoupling SMDs near WROOM long sides
  translate([12.0, 17.5, pcb_t]) smd_block(r1206, "#202020");
  translate([15.5, 17.5, pcb_t]) smd_block(r1206, "#202020");
  translate([12.0,  8.5, pcb_t]) smd_block(r1206, "#a06030");
  translate([15.5,  8.5, pcb_t]) smd_block(r1206, "#a06030");

  // Brand silkscreen rectangle (centered between regulator and WROOM)
  color(silk_color)
    translate([19.0, pcb_w / 2 - 2.0, pcb_t + 0.01])
      cube([7.5, 4.0, 0.05]);
}

esp32_devkit_38pin();
