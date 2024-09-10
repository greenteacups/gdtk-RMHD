-- ghostblood: Turbulent flow over a flat plate
-- Nick. N. Gibbons, based on simulations by Yu Chen
-- Conditions from:
--  "Transition of compressible high enthalpy boundary layer flow over a flat plate"
--  Y. He and R. G. Morgan
--  Aeronautical Journal, February 1994

config.solver_mode = "steady"
config.dimensions = 2
config.flux_calculator = "ldfss2"
config.viscous = true
config.turbulence_model = "spalart_allmaras_edwards"
config.with_local_time_stepping=true

config.extrema_clipping=false
config.epsilon_van_albada = 1e-3

-- Gas model and flow conditions to match Table 1, the first entry
nsp, nmodes, gm = setGasModel('ideal-air.gas')
p_inf = 3.25e3  -- Pa
u_inf = 2100.0  -- m/s
T_inf = 254     -- K

-- Set up gas state and update thermodynamic transfer coefficients
gas_inf = GasState:new{gm}
gas_inf.p = p_inf; gas_inf.T = T_inf
gm:updateThermoFromPT(gas_inf); gm:updateSoundSpeed(gas_inf); gm:updateTransCoeffs(gas_inf)

-- Turbulence quantities estimate
turb_lam_viscosity_ratio = 5.0 -- Transitional starting ratio from LARC website
nu_inf = gas_inf.mu/gas_inf.rho
nuhat_inf = turb_lam_viscosity_ratio*nu_inf

-- Set up flow state
inflow = FlowState:new{p=p_inf, T=T_inf, velx=u_inf, nuhat=nuhat_inf}

-- Geometry of the flow domain
L = 600.0e-3 -- metres
H = 0.20 * L
--
--
--    Flow ->                         ...----c
--                    inflow   ...----       |
--                   .....-----              |
--        d.....-----                        | outflow
--        |                                  |
--        a----------------------------------b
--                    wall
a = Vector3:new{x=0.0, y=0.0}; b = Vector3:new{x=L, y=0.0};
c = Vector3:new{x=L, y=H};     d = Vector3:new{x=0.0, y=1.0*H/4.0}
patch = CoonsPatch:new{p00=a, p10=b, p11=c, p01=d}

niv = 256+1; njv = 64+1; a = 2e-5;
cfx = RobertsFunction:new{end0=true,end1=false,beta=1.09}
cflist = {north=cfx, east=GeometricFunction:new{a=a/H,       r=1.2, N=njv},
          south=cfx, west=GeometricFunction:new{a=a/(H/4.0), r=1.2, N=njv}}

grd = StructuredGrid:new{psurface=patch, niv=niv, njv=njv, cfList=cflist}
grid0 = registerFluidGridArray{
   grid = grd,
   nib = 4,
   njb = 2,
   fsTag="inflow",
   bcTags={north="inflow",east="outflow",south="wall",west="inflow"}
}
identifyGridConnections()

flowDict = {}
flowDict["inflow"] = inflow

bcDict = {
   wall = WallBC_NoSlip_FixedT:new{Twall=300.0, group="wall"},
   inflow = InFlowBC_Supersonic:new{flowState=inflow},
   outflow = OutFlowBC_Simple:new{}
}

makeFluidBlocks(bcDict, flowDict)

-- loads settings
config.boundary_groups_for_loads = "wall"

NewtonKrylovGlobalConfig{
   number_of_steps_for_setting_reference_residuals = 0,
   max_newton_steps = 1200,
   stop_on_relative_residual = 1.0e-8,
   number_of_phases = 1,
   inviscid_cfl_only = true,
   use_line_search = false,
   use_physicality_check = true,
   max_linear_solver_iterations = 40,
   max_linear_solver_restarts = 0,
   use_scaling = true,
   frechet_derivative_perturbation = 1.0e-30,
   use_preconditioner = true,
   preconditioner_perturbation = 1.0e-30,
   preconditioner = "ilu",
   ilu_fill = 0,
   write_loads = true,
   total_snapshots = 2,
   steps_between_snapshots = 100,
   steps_between_diagnostics = 1,
   steps_between_loads_update = 1000000,
}

NewtonKrylovPhase:new{
   residual_interpolation_order = 2,
   jacobian_interpolation_order = 2,
   frozen_preconditioner = true,
   frozen_limiter_for_jacobian = false,
   use_adaptive_preconditioner = false,
   steps_between_preconditioner_update = 15,
   linear_solve_tolerance = 0.01,
   use_auto_cfl = true,
   threshold_relative_residual_for_cfl_growth = 0.1,
   start_cfl = 2.0,
   max_cfl = 1.0e4,
   auto_cfl_exponent = 0.8
}

