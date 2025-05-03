#include "common.h"
#include "wdb.h"

int main(int argc, char *argv[]) {
    //in millimeters
    //clip
    fastf_t clip_height=8;
    fastf_t clip_length=60;
    //trace
    fastf_t trace_width=0.52;
    fastf_t trace_gap=0.62;
    fastf_t trace_length=5;
    int number_of_traces=10;
    //junction
    fastf_t junction_length=clip_length/6;
    //wire
    fastf_t wire_width=1.6;
    fastf_t wire_gap=0.5;
    fastf_t wire_displace=clip_height/5;
    //clip width
    fastf_t traces_width=(trace_width+trace_gap)*number_of_traces;
    fastf_t wires_width=(wire_width+wire_gap)*number_of_traces;
    fastf_t junction_width=wires_width;

    //open db connection
    struct rt_wdb *wdbp;
    wdbp = wdb_fopen("soic_test_clip.g");
    if (!wdbp) {
        bu_log("Failed to open BRL-CAD database.\n");
        return 1;
    }
    
    //clip
    //traces cube
    point_t traces_cube_start={-traces_width/2,-clip_height/2,-trace_length/2};
    point_t traces_cube_end={traces_width/2,clip_height/2,trace_length/2};
    mk_rpp(wdbp,"traces_cube.s",traces_cube_start,traces_cube_end);
    //junction cube
    point_t junction_cube_start={-wires_width/2,-clip_height/2,-junction_length/2};
    point_t junction_cube_end={wires_width/2,clip_height/2,junction_length/2};
    mk_rpp(wdbp,"junction_cube.s",junction_cube_start,junction_cube_end);

    //put in a region
    mk_region1(wdbp,"clip.r","traces_cube.s","plastic","los",0);
    //log it
    bu_log("clip created\n");

    //close db connection
    wdb_close(wdbp);
    
    return 0;
}
