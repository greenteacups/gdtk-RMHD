/**
 * Module for doing preparation of grids.
 *
 * Authors: RJG, PJ, KAD, NNG
 * Date: 2022-08-08
 */

module prepgrids;

import std.getopt;
import std.stdio : writeln, writefln;
import std.string : toStringz;
import std.conv : to;
import std.path : dirName;
import std.file : thisExePath, exists;

import util.lua;
import geom.luawrap;

import lua_helper : initLuaStateForPrep;
import lmrconfig : lmrCfg;
import command;
import globalconfig;
import luaflowsolution;
import luaflowstate;

Command prepGridCmd;

static this()
{
    prepGridCmd.main = &main_;
    prepGridCmd.description = "Prepare grids for a simulation.";
    prepGridCmd.shortDescription = prepGridCmd.description;
    prepGridCmd.helpMsg =
`lmr prep-grids [options]

Prepare a grid or set of grids based on a file called job.lua.

options ([+] can be repeated):

 -v, --verbose [+]
     Increase verbosity during grid generation.
 -j, --job=grid.lua
     Specify the input file to be different from job.lua.

`;

}


void main_(string[] args)
{
    int verbosity = 0;
    string userGridName = lmrCfg.jobFile;
    getopt(args,
           config.bundling,
           "v|verbose+", &verbosity,
           "j|job", &userGridName,
           );

    if (verbosity > 0) {
        writeln("lmr prep-grids: Begin preparation of grid files.");
    }

    if (!exists(userGridName)) {
        writefln("The file %s does not seems to exist.", userGridName);
        writeln("Did you mean to specify a different job name?");
        return;
    }

    if (verbosity > 1) writeln("lmr prep-grids: Start lua connection.");
    auto L = initLuaStateForPrep();
    lua_pushinteger(L, verbosity);
    lua_setglobal(L, "verbosity");
    // Now that we have set the Lua interpreter context,
    // process the Lua scripts.
    if ( luaL_dofile(L, toStringz(dirName(thisExePath())~"/../lib/prepgrids.lua")) != 0 ) {
        writeln("There was a problem in the Eilmer Lua code: prepgrids.lua");
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    if ( luaL_dofile(L, toStringz(userGridName)) != 0 ) {
        writeln("There was a problem in the user-supplied input lua script: ", userGridName);
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    if ( luaL_dostring(L, "writeGridFiles()") != 0 ) {
        writeln("There was a problem in the Lua function writeGridFiles() in prepgrids.lua");
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    if (verbosity > 0) { writeln("lmr prep-grids: Done."); }
    return;
}
