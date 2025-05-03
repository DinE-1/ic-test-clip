#include "common.h"
#include "vmath.h"
#include "wdb.h"

int main(int argc, char *argv[]) {
    struct rt_wdb *wdbp;
    wdbp = wdb_fopen("cube.g");
    if (!wdbp) {
        bu_log("Failed to open BRL-CAD database.\n");
        return 1;
    }
    
    fastf_t vertices[24] = {
        0.0, 0.0, 0.0,
        1.0, 0.0, 0.0,
        1.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
        1.0, 0.0, 1.0,
        1.0, 1.0, 1.0,
        0.0, 1.0, 1.0
    };
    if (mk_arb8(wdbp, "cube.s", vertices) != 0) {
        bu_log("Failed to create cube.\n");
        return 1;
    }

    wdb_close(wdbp);
    return 0;
}
