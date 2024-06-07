-- grid.lua
print('EAST facility with 2D nozzle, as described by Sharma et al.')
-- PJ, 2021-11-20
--     2024-04-05 Adapt to Eilmer5 and set up just the nozzle expansion.
--
config.dimensions = 2

-- Geometry of shock tube and nozzle region
Rtube = 0.050
Xa = -0.150  -- inlet for simulation domain
Xb = -0.025  -- start of contraction for nozzle
             -- nozzle throat at x=0
Xc = 0.083   -- nozzle exit
Xd = 0.150   -- domain outlet is further along the shock tube

function y(x)
   -- Nozzle profile, units are metres.
   local n = x/0.0254
   return 0.0032*(1.0+n*n)
end

function xypath0(t)
   -- Parametric path with 0<=t<=1.
   local x = Xb*(1.0-t) + 0.0*t
   return {x=x, y=y(x)}
end

function xypath1(t)
   -- Parametric path with 0<=t<=1.
   local x = 0.0*(1.0-t) + Xc*t
   return {x=x, y=y(x)}
end

-- For node numbering, see PJ's notebook page 75, 2021-11-19
-- We build the domain in stages, starting with the nozzle.
b0 = {x=Xb-0.002, y=0.0}
b2 = {x=Xb, y=y(Xb)}; print("b2=", b2.x, b2.y)
b1 = {x=b0.x, y=0.5*b2.y}
g0 = {x=0.0, y=0.0}
g2 = {x=0.0, y=y(0.0)}; print("g2=", g2.x, g2.y)
c0 = {x=0.095, y=0.0}
c2 = {x=Xc, y=y(Xc)}; print("c2=", c2.x, c2.y)
c1 = {x=c0.x, y=0.5*c2.y}
c3 = {x=Xc, y=Rtube}
--
nozzle_inlet = Bezier:new{points={b0, b1, b2}}
nozzle_exit = Bezier:new{points={c0, c1, c2}}
nozzle_profile0 = LuaFnPath:new{luaFnName="xypath0"}
nozzle_profile1 = LuaFnPath:new{luaFnName="xypath1"}
nozzle_throat = Line:new{p0=g0, p1=g2}
nozzle_axis0 = Line:new{p0=b0, p1=g0}
nozzle_axis1 = Line:new{p0=g0, p1=c0}
quad0 = CoonsPatch:new{north=nozzle_profile0, east=nozzle_throat,
		       south=nozzle_axis0, west=nozzle_inlet}
quad1 = CoonsPatch:new{north=nozzle_profile1, east=nozzle_exit,
		       south=nozzle_axis1, west=nozzle_throat}
--
-- The downstream-end of shock tube.
a0 = {x=Xa, y=0.0}
e1 = {x=0.67*b2.x+0.33*Xa, y=b2.y+0.010}
a2 = {x=Xa, y=e1.y}
e2 = {x=0.33*b2.x+0.67*Xa, y=e1.y}
a3 = {x=Xa, y=Rtube}
b3 = {x=b2.x, y=Rtube}
--
tube_axis = Line:new{p0=a0, p1=b0}
tube_mid = Bezier:new{points={a2, e2, e1, b2}}
tube_wall = Line:new{p0=a3, p1=b3}
inlet0 = Line:new{p0=a0, p1=a2}
inlet1 = Line:new{p0=a2, p1=a3}
tube_end = Line:new{p0=b2, p1=b3}
--
quad2 = CoonsPatch:new{north=tube_mid, east=nozzle_inlet,
                       south=tube_axis, west=inlet0}
quad3 = CoonsPatch:new{north=tube_wall, east=tube_end,
                       south=tube_mid, west=inlet1}
--
-- Downstream from the nozzle exit.
d0 = {x=Xd, y=0.0}
d2 = {x=Xd, y=0.5*c2.y+0.5*c3.y}
d3 = {x=Xd, y=Rtube}
f1 = {x=0.67*c2.x+0.33*d2.x, y=d2.y}
f2 = {x=0.33*c2.x+0.67*d2.x, y=d2.y}
--
downstream_axis = Line:new{p0=c0, p1=d0}
downstream_mid = Bezier:new{points={c2, f1, f2, d2}}
downstream_wall = Line:new{p0=c3, p1=d3}
nozzle_end = Line:new{p0=c2, p1=c3}
outlet0 = Line:new{p0=d0, p1=d2}
outlet1 = Line:new{p0=d2, p1=d3}
--
quad4 = CoonsPatch:new{north=downstream_mid, east=outlet0,
                       south=downstream_axis, west=nozzle_exit}
quad5 = CoonsPatch:new{north=downstream_wall, east=outlet1,
                       south=downstream_mid, west=nozzle_end}
--
-- Grid
factor=1.0
nx0 = math.floor(40*factor)
ny0 = math.floor(10*factor)
cfx0 = RobertsFunction:new{end0=false, end1=true, beta=1.2}
grid0 = StructuredGrid:new{psurface=quad0, niv=nx0+1, njv=ny0+1,
                           cfList={north=cfx0, south=cfx0}}
cfx1 = RobertsFunction:new{end0=true, end1=false, beta=1.1}
grid1 = StructuredGrid:new{psurface=quad1, niv=nx0*2+1, njv=ny0+1,
                           cfList={north=cfx1, south=cfx1}}
grid2 = StructuredGrid:new{psurface=quad2, niv=nx0*4+1, njv=ny0+1}
cfy3 = RobertsFunction:new{end0=true, end1=false, beta=1.2}
grid3 = StructuredGrid:new{psurface=quad3, niv=nx0*4+1, njv=ny0*2+1,
                           cfList={east=cfy3}}
nx4 = nx0 // 2
ny5 = ny0 // 2
grid4 = StructuredGrid:new{psurface=quad4, niv=nx4+1, njv=ny0+1}
grid5 = StructuredGrid:new{psurface=quad5, niv=nx4+1, njv=ny5+1}
--
-- Register only the grids downstream of the nozzle throat.
-- We have retined the other parts of the geometry so that
-- we can do the shock-reflection region at a later date.
--
registerFluidGrid{grid=grid1, fsTag="initial", bcTags={west="inflow"}}
registerFluidGrid{grid=grid4, fsTag="initial", bcTags={east="outflow"}}
registerFluidGrid{grid=grid5, fsTag="initial", bcTags={east="outflow"}}
identifyGridConnections()
