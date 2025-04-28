//main clip side
length=50;
depth=5;

//trace
trace_width=0.52;
init_gap=0.5;
gap=0.62;

trace_depth=depth/2;
trace_displace=depth/5;
rubberband_cushion=depth/10;

//main clip width
width=(trace_width+gap)*(10) - gap ; // subtracting gap to make it symmetric and fix alignment

//rubberband
rubberband_width=length/20;
rubberband_depth=depth-(trace_depth+trace_displace) -rubberband_cushion;

//roundness for cylinder(number of sides)
$fn=30;

module clip_side(){
    union()
    difference(){
        cube([width,length,depth]);
        
        //trace
        for (i=[gap:trace_width+gap:width]){
            union(){
                translate([i,0,trace_displace]){
                    cube([trace_width,length,trace_depth]);
                }
                translate([i,0,0]){
                    cube([trace_width,length/10,depth]);
                }
            }
        };

        //slant
        rotate([50,0,0])
        translate([0,0,0])
        cube([width,sqrt(length*length + depth*depth), depth]);
        
        //rubberband
        translate([0,length/4,depth-rubberband_depth])
        cube([width,rubberband_width,rubberband_depth]);
        
    };
}

//shaft
shaft_outer_radius=6;
shaft_inner_radius=3;
shaft_cut_cushion=0;
module shaft(){
    difference(){
    
        //main shaft
        cylinder(width,shaft_outer_radius,shaft_outer_radius);
        //inner hole
        translate([0,0,shaft_cut_cushion])//for cutting front and back
        cylinder(width-2*shaft_cut_cushion,shaft_inner_radius,shaft_inner_radius);
    
    };
}

//shaft negative
module center_shaft_negative(cushion=0){
    cylinder_height=width/2 - cushion;
    translate([0,0,+cushion/2])
    difference(){
        cylinder(cylinder_height,shaft_outer_radius,shaft_outer_radius);
        cylinder(cylinder_height,shaft_inner_radius,shaft_inner_radius);
    }
}

//shaft rod
module shaft_rod(rod_dia_cushion=0){
    rod_len_cushion=(2*shaft_cut_cushion)+0.5;
    translate([0,0,rod_len_cushion/2]) // this is to center the rod
    cylinder(width-rod_len_cushion,shaft_inner_radius-rod_dia_cushion,shaft_inner_radius-rod_dia_cushion);
}

//main construction

//side 1
translate([0,0,trace_displace])
union(){
difference(){
    color("blue")
    union(){
        translate([0,0,shaft_outer_radius-trace_displace])
        clip_side();
        translate([0,length/2,0])
        rotate([0,90,0])
        shaft();
    }
    translate([width/4,length/2,0])
    rotate([0,90,0])
    center_shaft_negative(0);
}
}

//side 2
color("red")
translate([width,0,0])
union(){
    translate([0,0,-shaft_outer_radius+trace_displace])
    rotate([0,180,0])
    clip_side();
    rotate([0,90,0])
    translate([0,length/2,-(3*width/4)])
    center_shaft_negative(2);
};

//rod
color("pink",1)
rotate([0,90,0])
translate([0,length/2,0])
shaft_rod(1);
