// block.d
// Base class for blocks of cells, for use within the Eilmer flow solver.
// Kyle A. Damm 2020-02-11 first cut.

module block;

import std.stdio;
import globalconfig;
import util.lua;

// To distinguish ghost cells from active cells, we start their id values at
// an arbitrarily high value.  It seem high to me (PJ) but feel free to adjust it
// if you start using grids larger I expect.
enum ghost_cell_start_id = 1_000_000_000;

class Block {
public:
    int id;      // block identifier: assumed to be the same as the block number.
    string label;
    bool active; // if true, block participates in the time integration
                 // The active flag is used principally for the block-marching calculation,
                 // where we want to integrate a few blocks at a time.
    lua_State* myL;
    LocalConfig myConfig;

    this(int id, string label)
    {
        this.id = id;
        this.label = label;

        // Lua interpreter for the block.
        if (GlobalConfig.verbosity_level > 1) {
            writefln("Starting new Lua interpreter in Block blk.id=%d", id);
        }
        if (myL) {
            writefln("Oops, already have a nonzero pointer for Lua interpreter for blk.id=%d", id);
        } else {
            myL = luaL_newstate();
        }
        if (!myL) { throw new Error("Could not allocate memory for Lua interpreter."); }
        luaL_openlibs(myL);
        lua_pushinteger(myL, id);
        lua_setglobal(myL, "blkId");
    }

    void finalize()
    {
        if (myL) {
            lua_close(myL);
            myL = null;
        }
    }
} // end class Block
