//print error
print_error=0.2;

//main clip side
length=60;
depth=5;

//trace
trace_width=0.52;
init_gap=0.5;
trace_gap=0.62;
trace_length=5;

//wire
wire_width=1.6;
wire_gap=0.5;
wire_displace=depth/5;

//main clip width
width=(trace_width+trace_gap)*(10) - trace_gap ; // subtracting gap to make it symmetric and fix alignment
wires_width=(width/(trace_width+trace_gap)) * (wire_width+wire_gap);

//junction
junction_length=10;

//rubberband
rubberband_width=length/20;
rubberband_depth=3;

//smoothness for cylinder(number of sides)
$fn=10;

module clip_side(){
    traces_cube_displace=(wires_width-width)/2;
    union(){
    difference(){
        //main base
        union(){
            //traces cube
            translate([traces_cube_displace,0,0])
            cube([width,trace_length,depth]);
            //junction cube
            translate([0,trace_length,0])
            cube([wires_width,junction_length,depth]);
            //wires cube
            translate([0,trace_length+junction_length,0])
            cube([wires_width,length-trace_length-junction_length,depth]); 
        }

        //trace slit
        for (i=[trace_gap:trace_width+trace_gap:width-trace_gap]){
            translate([traces_cube_displace + i,0,0])
            cube([trace_width,trace_length,depth]);        
        }

        //number of traces(pins)
        traces_number=width/(trace_width+trace_gap);
        //width required for the number of traces number of wires to fit
        wires_width=(wire_width+wire_gap)*traces_number;

        //wire slit
        for (i=[wire_gap:wire_width+wire_gap:wires_width-wire_gap]){
            translate([i,trace_length+junction_length,wire_displace])
            cube([wire_width,length-trace_length-junction_length,depth-wire_displace]);
        };

        //slant
        rotate([50,0,0])
        translate([0,0,0])
        cube([wires_width,sqrt(length*length + depth*depth), depth]);
        
        //rubberband
        translate([0,length/3,depth-rubberband_depth])
        cube([wires_width,rubberband_width,rubberband_depth]);
    };
    };
}

//shaft
shaft_outer_radius=4;
shaft_inner_radius=3.5/2 + print_error;
shaft_height=length/5;
shaft_middle_width=width/2;
shaft_cut_cushion=0;
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
rod_len=width-rod_len_cushion;
module shaft_rod(rod_dia_cushion=0){
    translate([0,0,-rod_len/2]) // this is to center the rod
    cylinder(width-rod_len_cushion,shaft_inner_radius-rod_dia_cushion,shaft_inner_radius-rod_dia_cushion);
}

clip_shaft_displace=length/1.7;

//clip side with shaft ends
module clip_side_shaft(){
    clip_side();
    translate([wires_width/2,clip_shaft_displace,-shaft_height+wire_displace])
    rotate([90,0,90])
    ends_shaft(1,shaft_cut_cushion);
}

//side middle
module clip_middle_shaft(){
    rotate([0,180,0])
    clip_side();
    translate([-wires_width/2,clip_shaft_displace,shaft_height-wire_displace])
    rotate([-90,0,90])
    shaft(2.5);
}

clip_side();


translate([10,10,10]*10)
//main construction
union(){
    //side 1
    color("blue")
    rotate([0,180,0])
    translate([-wires_width-2,0,-depth])
    clip_side_shaft();

    //side 2
    color("red")
    translate([0,0,depth])
    clip_middle_shaft();

    //rod
    color("pink")
    rotate([90,90,0])
    translate([-shaft_inner_radius+0.5,2 + wires_width + shaft_inner_radius - 0.5 + 2 , -rod_len/2])
    shaft_rod(0.5);
}
