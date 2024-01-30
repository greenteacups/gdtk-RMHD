-- giant planet with ions CEA backed gas model with increased helium
-- This is based off the conditions from the work of Yu Liu:
-- Liu et al (2020) Using Aerothermodynamic Similarity to Experimentally Study Nonequilibrium Giant Planet Entry
-- Journal of Spacecraft and Rockets
-- Liu et al (2020) Experimental validation of a test gas substitution for simulating 
-- non‑equilibrium giant planet entry conditions in impulse facilities
-- Experiments in Fluids
-- I kept the species the same as the Uranus entry gas model
-- Chris James (c.james4@uq.edu.au) - 12/06/21
-- updated the trace to 1.0e-10 as running the CEA calculations in massf (which is the GDTk's only way to do it)
-- suppresses ionisation otherwise as electrons are very light so their mass fraction is very small
-- Chris James (c.james4@uq.edu.au) - 19/01/24

model = "CEAGas"

CEAGas = {
  mixtureName = 'giant-planet-h2-80-he',
  speciesList = {"H2","H","He","H+","He+","e-"},
  reactants = {H2=0.2, He=0.8},
  inputUnits = "moles",
  withIons = true,
  trace = 1.0e-10
}
