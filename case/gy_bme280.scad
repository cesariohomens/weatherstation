//
// GY-BME280 Realistic 3D Model
// Corrected version:
// - Purple PCB only
// - Gold pads only on vias/pins/holes
// - Realistic plated mounting holes
// - Through-hole header pins
//

$fn = is_undef(ENCLOSURE_BUILD) ? 96 : 48;

// ======================================================
// PCB DIMENSIONS
// ======================================================

pcb_width  = 15.5;
pcb_height = 12.0;
pcb_thickness = 1.6;

bme_pcb_w     = pcb_width;
bme_pcb_h     = pcb_height;
bme_pcb_t     = pcb_thickness;
bme_pcb_color = [0.45, 0.1, 0.55];

// Mount holes — centered at corners, sized to PCB edges (keep centers)
mount_x = 2.3;
mount_y = 2.2;
mount_max_r = min(mount_x, mount_y, pcb_width - mount_x, pcb_height - mount_y);
mount_hole_d = 3.0;
mount_ring_d = mount_max_r * 2;   // 4.4 mm — pad ring flush with board edges

// Header pins
pin_pitch = 2.54;
pin_count = 6;
pin_hole_d = 1.0;
pin_pad_d = 1.9;

// ======================================================
// COLORS
// ======================================================

pcb_color = bme_pcb_color;
gold      = [0.92,0.73,0.18];
silver    = [0.85,0.85,0.85];
black     = [0.08,0.08,0.08];
ceramic   = [0.82,0.77,0.68];

// ======================================================
// GOLD RING
// ======================================================

module gold_ring(outer_d, inner_d, h=0.06)
{
    color(gold)
    difference()
    {
        cylinder(d=outer_d, h=h);

        translate([0,0,-0.1])
            cylinder(d=inner_d, h=h+0.2);
    }
}

// ======================================================
// PCB
// ======================================================

module bme_pcb()
{
    color(bme_pcb_color)
    difference()
    {
        cube([bme_pcb_w, bme_pcb_h, bme_pcb_t]);

        // Mounting holes
        translate([mount_x, mount_y, -1])
            cylinder(d=mount_hole_d, h=5);

        translate([bme_pcb_w-mount_x, mount_y, -1])
            cylinder(d=mount_hole_d, h=5);

        // Header holes
        for(i=[0:pin_count-1])
        {
            translate([
                1.4 + i*pin_pitch,
                bme_pcb_h - 1.5,
                -1
            ])
            cylinder(d=pin_hole_d, h=5);
        }
    }
}

// ======================================================
// HEADER GOLD PADS
// ======================================================

module header_gold_pads()
{
    for(i=[0:pin_count-1])
    {
        translate([
            1.4 + i*pin_pitch,
            pcb_height - 1.5,
            pcb_thickness
        ])
        gold_ring(
            outer_d = pin_pad_d,
            inner_d = pin_hole_d
        );
    }
}

// ======================================================
// MOUNTING HOLE GOLD RINGS
// ======================================================

module mounting_gold_rings()
{
    translate([mount_x, mount_y, pcb_thickness])
        gold_ring(
            outer_d = mount_ring_d,
            inner_d = mount_hole_d
        );

    translate([pcb_width-mount_x, mount_y, pcb_thickness])
        gold_ring(
            outer_d = mount_ring_d,
            inner_d = mount_hole_d
        );
}

// ======================================================
// HEADER PINS
// ======================================================

module header_pins()
{
    for(i=[0:pin_count-1])
    {
        // Gold pin through PCB
        translate([
            1.4 + i*pin_pitch,
            pcb_height - 1.5,
            -3
        ])
        color(gold)
        cylinder(d=0.64, h=6);

        // Black spacer
        translate([
            1.4 + i*pin_pitch - 0.55,
            pcb_height - 1.5 - 0.55,
            pcb_thickness + 0.1
        ])
        color(black)
        cube([1.1,1.1,2]);

        // Upper square pin
        translate([
            1.4 + i*pin_pitch - 0.32,
            pcb_height - 1.5 - 0.32,
            pcb_thickness + 2.1
        ])
        color(gold)
        cube([0.64,0.64,6]);
    }
}

// ======================================================
// SMD RESISTOR
// ======================================================

module smd_resistor(x,y)
{
    translate([x,y,pcb_thickness])
    {
        // Gold pads
        color(gold)
        cube([0.35,1.0,0.05]);

        color(gold)
        translate([1.35,0,0])
            cube([0.35,1.0,0.05]);

        // Silver terminals
        color(silver)
        translate([0.15,0,0.05])
            cube([0.25,1.0,0.2]);

        color(silver)
        translate([1.3,0,0.05])
            cube([0.25,1.0,0.2]);

        // Body
        color(black)
        translate([0.35,0,0.05])
            cube([1.0,1.0,0.45]);
    }
}

// ======================================================
// SMD CAPACITOR
// ======================================================

module smd_capacitor(x,y,w=1.2,h=0.8)
{
    translate([x,y,pcb_thickness])
    {
        // Gold pads
        color(gold)
        cube([0.25,h,0.05]);

        color(gold)
        translate([w+0.25,0,0])
            cube([0.25,h,0.05]);

        // Metal terminals
        color(silver)
        translate([0.12,0,0.05])
            cube([0.2,h,0.2]);

        color(silver)
        translate([w+0.18,0,0.05])
            cube([0.2,h,0.2]);

        // Ceramic body
        color(ceramic)
        translate([0.25,0,0.05])
            cube([w,h,0.5]);
    }
}

// ======================================================
// BME280 SENSOR PACKAGE
// ======================================================

module bme280_chip(x,y)
{
    translate([x,y,pcb_thickness])
    {
        // Gold pads
        for(px=[0,2.6])
        {
            for(py=[0.15,0.95,1.75])
            {
                color(gold)
                translate([px,py,0])
                    cube([0.4,0.35,0.05]);
            }
        }

        // Main metal lid
        color(silver)
        cube([3.0,3.0,1.0]);

        // Sensor cavity
        color([0.15,0.15,0.15])
        translate([0.7,0.7,0.2])
            cube([1.6,1.6,0.3]);

        // Side contacts
        for(px=[0,2.6])
        {
            for(py=[0.2,1.0,1.8])
            {
                color(silver)
                translate([px,py,-0.05])
                    cube([0.4,0.3,0.15]);
            }
        }
    }
}

// ======================================================
// VISUAL PCB TRACES
// ======================================================

module traces()
{
    color([0.35,0.0,0.45])
    {
        translate([1.5,8.7,pcb_thickness+0.01])
            cube([12.0,0.16,0.02]);

        translate([2.1,7.0,pcb_thickness+0.01])
            cube([10.2,0.16,0.02]);

        translate([3.5,5.5,pcb_thickness+0.01])
            cube([7.2,0.16,0.02]);
    }
}

// ======================================================
// FULL ASSEMBLY
// ======================================================

module gy_bme280()
{
    bme_pcb();

    traces();

    // Gold plated pads
    header_gold_pads();

    // Gold mounting rings
    mounting_gold_rings();

    // Resistors
    smd_resistor(3.2,7.7);
    smd_resistor(5.5,7.7);
    smd_resistor(7.8,7.7);
    smd_resistor(10.1,7.7);

    // Top capacitor
    smd_capacitor(12.2,7.7,0.7,1.0);

    // Main sensor
    bme280_chip(6.2,4.2);

    // Bottom capacitor
    smd_capacitor(6.2,1.0,1.4,0.8);

    // Header pins
    header_pins();
}

if (is_undef(ENCLOSURE_BUILD))
  gy_bme280();