-- Uranus entry gas based on the outer atmospheric compoisition of Uranus
-- From Conrath et al. (1987) The Helium Abundance of Uranus from Voyager Measurements
-- Journal of Geophysical Research
-- which found the helium mole fraction in the upper troposphere of Uranus 
-- (where methane is insignificant) to be 0.152 +- 0.033.
-- This is often approximated as a gas composition of 85%H2/15%He (by volume)
-- as was performed in James et al. (2020) Experimentally Simulating Giant Planet Entry in an Expansion Tube
-- Journal of Spacecraft and Rockets
-- and Palmer et al. (2014) Aeroheating Uncertainties in Uranus and Saturn Entries by the Monte Carlo Method
-- Journal of Spacecraft and Rockets
-- I got the species list from very high temperature (14,000 K) H2/He post-shock calculations using the old PITOT code.
-- Chris James (c.james4@uq.edu.au) - 12/06/21
-- updated the trace to 1.0e-10 as running the CEA calculations in massf (which is the GDTk's only way to do it)
-- suppresses ionisation otherwise as electrons are very light so their mass fraction is very small
-- Chris James (c.james4@uq.edu.au) - 19/01/24

model = "CEAGas"

CEAGas = {
  mixtureName = 'uranus',
  speciesList = {"H2","H","He","H+","He+","e-"},
  reactants = {H2=0.85, He=0.15},
  inputUnits = "moles",
  withIons = true,
  trace = 1.0e-10
}
