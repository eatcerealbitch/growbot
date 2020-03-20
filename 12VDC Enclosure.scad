/* $Id: snapbox.scad,v 1.22 2019/07/17 05:56:43 tobi Exp $ */

// Simple snap click box with rounded corners and a uniform
// wall thickness; optional: screw holes and poles

// Remix of https://www.thingiverse.com/thing:3745192

///////////////////////////////////////////////////////////////////////////////////////////////
//
// REQUIREMENTS:
//
// pcb length  =  63.2 mm 
// pcb width   =  44.2 mm
// PCB height  =  27.5 mm
// wire hole   =  5.0  mm 
//           (wires = 1.6 so 3.2^2 + 3.2^ = c^2 so c = 4.5254834 then add some for shrink tube.
//
///////////////////////////////////////////////////////////////////////////////////////////////


$fn=100;

// inner (!) dimensions of the box and the lid
// only the inner corner radius is subtracted from those

box_x = 75;
box_y = 42;
box_z = 15;  // obox: height including the outer rim
lid_z = 3;   // ibox: height of the lid excluding wall and inner rim

wall = 3.0;  // thickness of side walls, floor and ceiling
rim = wall;  // z_height of the lip; xy_thickness is wall/2
tol = 2.2*.15; // tolerance, depends on your printer/settings

// offset radius for rounded corners with uniform wall thickness
icr = 2;     // inner corner radius; outer = (icr+wall)

snap = .17;  // radius of the snap click springs/grooves, zero=none

// set this to true if you want poles and screw holes
with_screws = true;

// box part with outer rim
module obox() {
  rect = [ box_x-2*icr, box_y-2*icr ];
  difference() {

    // box
    translate([wall+box_x/2,wall+box_y/2,0]) {
      difference() {
        linear_extrude(height=wall+box_z) // main block
          offset(r=icr+wall) square(rect, center=true);
        translate([0,0,wall]) linear_extrude(height=box_z+.01)
          offset(r=icr) square(rect, center=true); // inner cut-out
        translate([0,0,wall+box_z-rim]) linear_extrude(height=rim+.01)
          offset(r=icr+wall/2+tol/2) square(rect, center=true); // outer rim
      }
    }

    // snap grooves
    translate([wall+box_x/4-tol/2, wall/2-tol/2, wall+box_z-rim/2]) {
      hull() {
        sphere(r=1.1*snap, $fn=42);
        translate([box_x/2+tol/2,0,0]) sphere(r=snap, $fn=42);
      }
    }
    translate([wall+box_x/4-tol/2, wall+box_y+wall/2+tol/2, wall+box_z-rim/2]) {
      hull() {
        sphere(r=1.1*snap, $fn=42);
        translate([box_x/2+tol/2,0,0]) sphere(r=snap, $fn=42);
      }
    }

  }
}

// box part with inner rim (lid)
module ibox() {
  rect = [ box_x-2*icr, box_y-2*icr ];
  union() {

    // lid
    translate([wall+box_x/2,wall+box_y/2,0]) {
      difference() { // main block with inner cut-out
        linear_extrude(height=wall+lid_z)
          offset(r=icr+wall) square(rect, center=true);
        translate([0,0,wall-.01]) linear_extrude(height=lid_z+rim+.02)
          offset(r=icr) square(rect, center=true);
      }
      translate([0,0,wall+lid_z]) difference() { // inner rim
        linear_extrude(height=rim)
          offset(r=icr+wall/2-tol/2) square(rect, center=true);
        translate([0,0,-.01]) linear_extrude(height=rim+.02)
          offset(r=icr) square(rect, center=true);
      }
    }

    // snap click springs
    translate([wall+box_x/4+tol/2, wall/2+tol/2, wall+lid_z+rim/2]) {
      hull() {
        sphere(r=snap, $fn=42);
        translate([box_x/2-tol/2,0,0]) sphere(r=snap, $fn=42);
      }
    }
    translate([wall+box_x/4+tol/2, wall+box_y+wall/2-tol/2, wall+lid_z+rim/2]) {
      hull() {
        sphere(r=snap, $fn=42);
        translate([box_x/2-tol/2,0,0]) sphere(r=snap, $fn=42);
      }
    }

  }
}


// ----- poles and ribs for screws (optional) -----

pr = 6.0/2; // pole radius
sr = 2.6/2 + .1; // screw radius
rib = wall/2; // rib thickness
pw = wall/3; // pole to wall distance

module poles_with_ribs(height) {

  // width of the stress relief slit in the pole (zero = none)
  ss = rib/3;

  // bottom left
  translate([wall+pr+pw, wall+pr+pw, wall]) {
    difference() {
      cylinder(r=pr, h=height); // pole
      translate([0, 0, 1]) rotate([0,0,45]) // vertical cut
        translate([0,-ss/2,0]) cube([2*pr,ss,height+.01]);
    }
    translate([-pr-pw-.1, -rib/2, 0]) // left rib
      cube([pw+pr, rib, height]);
    translate([-rib/2, -pr-pw-.1, 0]) // bottom rib
      cube([rib, pr+pw, height]);
  }

  // bottom right
  translate([wall+box_x-pr-pw, wall+pr+pw, wall]) {
    difference() {
      cylinder(r=pr, h=height); // pole
      translate([0, 0, 1]) rotate([0,0,45+90]) // vertical cut
        translate([0,-ss/2,0]) cube([2*pr,ss,height+.01]);
    }
    translate([.1, -rib/2, 0]) // right rib
      cube([pw+pr, rib, height]);
    translate([-rib/2, -pr-pw-.1, 0]) // bottom rib
      cube([rib, pr+pw, height]);
  }

  // top right
  translate([wall+box_x-pr-pw, wall+box_y-pr-pw, wall]) {
    difference() {
      cylinder(r=pr, h=height); // pole
      translate([0, 0, 1]) rotate([0,0,-45-90]) // vertical cut
        translate([0,-ss/2,0]) cube([2*pr,ss,height+.01]);
    }
    translate([.1, -rib/2, 0]) // right rib
      cube([pw+pr, rib, height]);
    translate([-rib/2, .1, 0]) // top rib
      cube([rib, pr+pw, height]);
  }

  // top left
  translate([wall+pr+pw, wall+box_y-pr-pw, wall]) {
    difference() {
      cylinder(r=pr, h=height); // pole
      translate([0, 0, 1]) rotate([0,0,45-90]) // vertical cut
        translate([0,-ss/2,0]) cube([2*pr,ss,height+.01]);
    }
    translate([-pr-pw-.1, -rib/2, 0]) // left rib
      cube([pw+pr, rib, height]);
    translate([-rib/2, .1, 0]) // top rib
      cube([rib, pr+pw, height]);
  }
}

// ----- main parts -----

module make_lid() {

  // screw head radius (shr) and z-height (shz)
  shr = 4.9/2; shz = 2.0;  // spax 2.5 x 16
//  shr = 5.9/2;  shz = 2.5;  // spax 2.5 x 25

  difference() {
    union() {
      ibox();
      if(with_screws) poles_with_ribs(lid_z+rim);
    }

    if(with_screws) { // drill holes
      translate([wall+pr+pw, wall+pr+pw, -.01]) { // bl
        cylinder(r=sr+.1, h=wall+lid_z+rim+.02);
        cylinder(r1=shr, r2=sr+.1, h=shz); // screw head
      }
      translate([wall+box_x-pr-pw, wall+pr+pw, -.01]) { // br
        cylinder(r=sr+.1, h=wall+lid_z+rim+.02);
        cylinder(r1=shr, r2=sr+.1, h=shz); // screw head
      }
      translate([wall+box_x-pr-pw, wall+box_y-pr-pw, -.01]) { // tr
        cylinder(r=sr+.1, h=wall+lid_z+rim+.02);
        cylinder(r1=shr, r2=sr+.1, h=shz); // screw head
      }
      translate([wall+pr+pw, wall+box_y-pr-pw, -.01]) { // tl
        cylinder(r=sr+.1, h=wall+lid_z+rim+.02);
        cylinder(r1=shr, r2=sr+.1, h=shz); // screw head
      }
    }

    // ventilation slits (grill)
    for (x = [wall+box_x/4:1.5:wall+3*box_x/4]) {
      translate([x, wall+box_y/4, -.01])
        cube([.75, box_y/2, wall+.02]);
    }

  }


  // this asymmetry goes with the notch
  // it makes the lid fit only one way
  translate([-.01, wall+box_y/4+tol/2, wall+lid_z])
    cube([wall/2+.02, box_y/2-tol, rim/2+.01]);

}

module make_box() {
  difference() {

    union() {
      obox();
      if(with_screws) poles_with_ribs(box_z-rim);
    }

    if(with_screws) { // drill holes
      translate([wall+pr+pw, wall+pr+pw, wall+.01])  // bl
        cylinder(r=sr, h=box_z-rim);
      translate([wall+box_x-pr-pw, wall+pr+pw, wall+.01])  // br
        cylinder(r=sr, h=box_z-rim);
      translate([wall+box_x-pr-pw, wall+box_y-pr-pw, wall+.01]) // tr
        cylinder(r=sr, h=box_z-rim);
      translate([wall+pr+pw, wall+box_y-pr-pw, wall+.01]) // tl
        cylinder(r=sr, h=box_z-rim);
    }

    // finger nail groove on the right, short side of the rim
    translate([wall+box_x+wall, wall+box_y/4, wall+box_z]) {
      hull() {
        sphere(r=wall/4, $fn=42);
        translate([0,box_y/2,0]) sphere(r=wall/4, $fn=42);
      }
    }

    // notch on the left, short side of the rim
    translate([-.01, wall+box_y/4-tol/2, wall+box_z-rim/2])
      cube([wall/2+.02, box_y/2+tol, rim/2+.01]);

    // power supply holes
    translate([-.01, wall+box_y/2, wall+box_z/2-rim/2]) {
      hull() { // teardrop
        rotate([0, 90, 0]) cylinder(h=wall+.02, d=3);
        translate([0,0,6.75/3.14])
          rotate([0, 90, 0]) cylinder(h=wall+.02, d=6/2);
      }
    }

    translate([wall+box_x-.01, wall+box_y/2, wall+box_z/2-rim/2]) {
      hull() { // teardrop
        rotate([0, 90, 0]) cylinder(h=wall+.02, d=3);
        translate([0,0,6.75/3.14])
          rotate([0, 90, 0]) cylinder(h=wall+.02, d=6/2);
      }
    }

    // ventilation slits (grill)
*    for (x = [wall+box_x/4:1.5:wall+3*box_x/4]) {
      translate([x, wall+box_y/4, -.01])
        cube([.75, box_y/2, wall+.02]);
    }

  }
}

// place parts for printing
translate([0, wall+box_y+wall+5, 0]) make_lid();
translate([0, 0, 0]) make_box();

// eof
