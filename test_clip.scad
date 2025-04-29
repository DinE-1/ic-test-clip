//main clip side
length=60;
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

//smoothness for cylinder(number of sides)
$fn=20;

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
shaft_outer_radius=width/2;
shaft_inner_radius=shaft_outer_radius/1.5;
shaft_height=length/5;
shaft_middle_width=width/2;
shaft_cut_cushion=0.5;

module shaft(cushion=0,s_width=shaft_middle_width, shaft_cut=0){
    cylinder_height=s_width - cushion;    
    translate([0,0,-cylinder_height/2])//center it
    difference(){
        union(){
            translate([-shaft_outer_radius,0,0])
            cube([2*shaft_outer_radius,shaft_height,cylinder_height]);
            cylinder(cylinder_height,shaft_outer_radius,shaft_outer_radius);
        };
        translate([0,0,shaft_cut])
        cylinder(cylinder_height-2*shaft_cut,shaft_inner_radius,shaft_inner_radius);
    };
}
//abstraction for shaft ends
module ends_shaft(cushion=0, shaft_cut=0){
    difference(){
        //main shaft
        shaft(0,width,shaft_cut);

        //remove center piece
        shaft(0,shaft_middle_width-cushion);
    
    };
}

//shaft rod
rod_len_cushion=0.5 + 2*shaft_cut_cushion;
module shaft_rod(rod_dia_cushion=0){
    rod_len=width-rod_len_cushion;
    translate([0,0,-rod_len/2]) // this is to center the rod
    cylinder(width-rod_len_cushion,shaft_inner_radius-rod_dia_cushion,shaft_inner_radius-rod_dia_cushion);
}

//translate([10,10,10]*5)
//main construction
union(){
clip_shaft_displace=length/1.7;

//side 1
color("blue")
translate([0,0,-2*trace_displace])
union(){
    translate([-width,0,2*shaft_height])
    clip_side();
    translate([-width/2,clip_shaft_displace,shaft_height+trace_displace])
    rotate([90,0,90])
    ends_shaft(1,shaft_cut_cushion);

};

//side 2
color("red")
union(){
    rotate([0,180,0])
    clip_side();
    translate([-width/2,clip_shaft_displace,shaft_height-trace_displace])
    rotate([-90,0,90])
    shaft(2.5);
};

//rod
color("pink")
rotate([0,90,0])
translate([-shaft_height+trace_displace,clip_shaft_displace,-width/2])
shaft_rod(0.5);
}
