/**
 * Module for doing preparation of flow fields and simulation parameters.
 *
 * Authors: RJG, PJ, KAD, NNG
 * Date: 2022-08-09
 * History:
 *   2024-02-11 -- Renamed module: prepflow --> prepsim
 *                 to better reflect its more general role
 */

module prepsim;

import std.getopt;
import std.stdio : writeln, writefln;
import std.string : toStringz, strip, split, format;
import std.conv : to;
import std.path : dirName;
import std.file : thisExePath, exists;
import std.json : JSONValue;
import std.algorithm : sort, uniq;

import util.lua;
import util.lua_service : getString;
import geom.luawrap;
import gas;
import gas.luagas_model;
import nm.luabbla;

import json_helper;
import lua_helper : initLuaStateForPrep;
import lmrconfig : lmrCfg;
import command;
import globalconfig;
import luaflowsolution;
import luaflowstate;
import luaidealgasflow;
import luagasflow;
import blockio : luafn_writeFlowMetadata, luafn_writeInitialFlowFile;

Command prepSimCmd;

static this()
{
    prepSimCmd.main = &main_;
    prepSimCmd.description = "Prepare initial flow fields and parameters for a simulation.";
    prepSimCmd.shortDescription = prepSimCmd.description;
    prepSimCmd.helpMsg =
`lmr prep-sim [options]

Prepare an initial flow field and simulation parameters based on a file called job.lua.

options ([+] can be repeated):

 -v, --verbose [+]
     Increase verbosity during preparation of the simulation files.

 -j, --job=flow.lua
     Specify the input file to be different from job.luu (default).
     default: job.lua
`;

}

void main_(string[] args)
{
    string blocksForPrep = "";
    int verbosity = 0;
    string userFlowName = lmrCfg.jobFile;
    getopt(args,
           config.bundling,
           "v|verbose+", &verbosity,
           "j|job", &userFlowName,
           );

    if (verbosity > 1) { writeln("lmr prep-sim: Start lua connection."); }

    auto L = initLuaStateForPrep();
    lua_pushinteger(L, verbosity);
    lua_setglobal(L, "verbosity");
    // RJG, 2023-06-27
    // Add a few more lua-wrapped functions for use in prep.
    // These functions are not backported into Eilmer 4, and
    // I don't want to hijack initLuaStateForPrep() just yet.
    // At some point in the future, this can be handled inside
    // initLuaStateForPrep().
    lua_pushcfunction(L, &luafn_writeFlowMetadata);
    lua_setglobal(L, "writeFlowMetadata");
    lua_pushcfunction(L, &luafn_writeInitialFlowFile);
    lua_setglobal(L, "writeInitialFlowFile");

    // Determine which fluidBlocks we need to process.
    int[] blockIdList;
    blocksForPrep = blocksForPrep.strip();
    foreach (blkStr; blocksForPrep.split(",")) {
        blkStr = blkStr.strip();
        auto blkRange = blkStr.split("..<");
        if (blkRange.length == 1) {
            blockIdList ~= to!int(blkRange[0]);
        }
        else if (blkRange.length == 2) {
            auto start = to!int(blkRange[0]);
            auto end = to!int(blkRange[1]);
            if (end < start) {
                string errMsg = "Supplied block list is in error. Range given is not allowed.";
                errMsg ~= format("Bad supplied range is: %s", blkStr);
                throw new UserInputError(errMsg);
            }
            foreach (i; start .. end) {
                blockIdList ~= i;
            }
        }
        else {
            string errMsg = "Supplied block list is in error. Range given is not allowed.";
            errMsg ~= format("Bad supplied range is: %s", blkStr);
            throw new UserInputError(errMsg);
        }
    }
    // Let's sort blocks in ascending order
    blockIdList.sort();
    lua_newtable(L);
    lua_setglobal(L, "fluidBlockIdsForPrep");
    lua_getglobal(L, "fluidBlockIdsForPrep");
    // Use uniq so that we remove any duplicates the user might have supplied
    import std.range;
    foreach (i, blkId; blockIdList.uniq().enumerate(1)) {
        lua_pushinteger(L, blkId);
        lua_rawseti(L, -2, to!int(i));
    }
    lua_pop(L, 1);
    // Now that we have set the Lua interpreter context,
    // process the Lua scripts.
    if (luaL_dofile(L, toStringz(dirName(thisExePath())~"/../lib/prepsim.lua")) != 0) {
        writeln("There was a problem in the Eilmer Lua code: prepsim.lua");
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    if (luaL_dostring(L, toStringz("readGridMetadata()")) != 0) {
        writeln("There was a problem in the Eilmer build function readGridMetadata() in prepsim.lua");
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    //
    // We are ready for the user's input script.
    if (!exists(userFlowName)) {
        writefln("The file %s does not seems to exist.", userFlowName);
        writeln("Did you mean to specify a different job name?");
        return;
    }
    if (luaL_dofile(L, toStringz(userFlowName)) != 0) {
        writeln("There was a problem in the user-supplied input lua script: ", userFlowName);
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    //
    if (luaL_dostring(L, toStringz("buildRuntimeConfigFiles()")) != 0) {
        writeln("There was a problem in the Eilmer build function buildRuntimeConfigFiles() in prepsim.lua");
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    JSONValue jsonData = readJSONfile(lmrCfg.cfgFile);
    set_config_for_core(jsonData);
    // We may not proceed to building of block files if the config parameters are incompatible.
    checkGlobalConfig();
    if (luaL_dostring(L, toStringz("buildFlowAndGridFiles()")) != 0) {
        writeln("There was a problem in the Eilmer build function buildFlowAndGridFiles() in prepsim.lua");
        string errMsg = to!string(lua_tostring(L, -1));
        throw new FlowSolverException(errMsg);
    }
    if (verbosity > 0) { writeln("lmr prep-sim: Done."); }

    return;
}


