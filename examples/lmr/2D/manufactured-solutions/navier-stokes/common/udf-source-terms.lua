-- udf-source-template.lua
-- Lua template for the source terms of a Manufactured Solution.
--
-- PJ, 29-May-2011
-- RJG, 06-Jun-2014
--   Declared maths functions as local

local sin = math.sin
local cos = math.cos
local exp = math.exp
local pi = math.pi

function sourceTerms(t, cell)
   src = {}
   x = cell.x
   y = cell.y


fmass = (9.9*pi*x*sin(2.827433388230814*x*y) + 4.0*pi*cos(3.1415926535897932*y))*(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0) + (-0.1*pi*x*sin(3.9269908169872415*x*y) - 0.15*pi*sin(3.1415926535897932*y))*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) - 11.0*cos(2.827433388230814*x*y) +90.0) + (-4.2*pi*y*sin(1.8849555921538759*x*y) +6.66666666666667*pi*cos(5.235987755982989*x))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0) + (-0.1*pi*y*sin(3.9269908169872415*x*y) + 0.075*pi*cos(2.3561944901923449*x))*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) +70.0)



fxmom = 25.2*pi^2*x^2*cos(1.8849555921538759*x*y) - 29.7*pi^2*x*y*cos(2.827433388230814*x*y) + 33.6*pi^2*y^2*cos(1.8849555921538759*x*y) - 18750.0*pi*y*cos(2.3561944901923449*x*y) + (-4.2*pi*x*sin(1.8849555921538759*x*y) + 18.0*pi*sin(4.7123889803846899*y))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) -11.0*cos(2.827433388230814*x*y) + 90.0) + (9.9*pi*x*sin(2.827433388230814*x*y) + 4.0*pi*cos(3.1415926535897932*y))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0)*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) +70.0) + (-0.1*pi*x*sin(3.9269908169872415*x*y) - 0.15*pi*sin(3.1415926535897932*y))*(4.0*sin(5.235987755982989*x) -12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) + 70.0)*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) -11.0*cos(2.827433388230814*x*y) + 90.0) + 4900.0*(-0.12*pi*y*sin(1.8849555921538759*x*y) + 0.19047619047619*pi*cos(5.235987755982989*x))*(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0)*(0.0571428571428571*sin(5.235987755982989*x) - 0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1) + 4900.0*(-0.1*pi*y*sin(3.9269908169872415*x*y) + 0.075*pi*cos(2.3561944901923449*x))*(0.0571428571428571*sin(5.235987755982989*x) - 0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1)^2 + 30000.0*pi*sin(3.1415926535897932*x) +148.148148148148*pi^2*sin(5.235987755982989*x) - 33.0*pi*sin(2.827433388230814*x*y) - 270.0*pi^2*cos(4.7123889803846899*y)



fymom = -118.8*pi^2*x^2*cos(2.827433388230814*x*y) + 8.4*pi^2*x*y*cos(1.8849555921538759*x*y) - 18750.0*pi*x*cos(2.3561944901923449*x*y) - 89.1*pi^2*y^2*cos(2.827433388230814*x*y) + 8100.0*(0.22*pi*x*sin(2.827433388230814*x*y) + 0.0888888888888889*pi*cos(3.1415926535897932*y))*(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0)*(0.0444444444444444*sin(3.1415926535897932*y) - 0.222222222222222*cos(4.7123889803846899*x) - 0.122222222222222*cos(2.827433388230814*x*y) + 1) + 8100.0*(-0.1*pi*x*sin(3.9269908169872415*x*y) - 0.15*pi*sin(3.1415926535897932*y))*(0.0444444444444444*sin(3.1415926535897932*y) -0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1)^2 + (-4.2*pi*y*sin(1.8849555921538759*x*y) + 6.66666666666667*pi*cos(5.235987755982989*x))*(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0)*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) -11.0*cos(2.827433388230814*x*y) + 90.0) + (9.9*pi*y*sin(2.827433388230814*x*y) + 30.0*pi*sin(4.7123889803846899*x))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0)*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) +70.0) + (-0.1*pi*y*sin(3.9269908169872415*x*y) + 0.075*pi*cos(2.3561944901923449*x))*(4.0*sin(5.235987755982989*x) -12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) + 70.0)*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) -11.0*cos(2.827433388230814*x*y) + 90.0) +53.3333333333333*pi^2*sin(3.1415926535897932*y) + 14.0*pi*sin(1.8849555921538759*x*y) - 450.0*pi^2*cos(4.7123889803846899*x) + 25000.0*pi*cos(3.9269908169872415*y)



fe = -(-4.2*pi*x*sin(1.8849555921538759*x*y) + 18.0*pi*sin(4.7123889803846899*y))*(-42.0*pi*x*sin(1.8849555921538759*x*y) + 99.0*pi*y*sin(2.827433388230814*x*y) + 300.0*pi*sin(4.7123889803846899*x) + 180.0*pi*sin(4.7123889803846899*y)) + (9.9*pi*x*sin(2.827433388230814*x*y) + 4.0*pi*cos(3.1415926535897932*y))*(2450.0*(0.0571428571428571*sin(5.235987755982989*x) - 0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1)^2 + 4050.0*(0.0444444444444444*sin(3.1415926535897932*y) - 0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1)^2 + 2.5*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0) - (9.9*pi*x*sin(2.827433388230814*x*y) + 4.0*pi*cos(3.1415926535897932*y))*(132.0*pi*x*sin(2.827433388230814*x*y) + 28.0*pi*y*sin(1.8849555921538759*x*y) -44.4444444444444*pi*cos(5.235987755982989*x) +53.3333333333333*pi*cos(3.1415926535897932*y)) + (9.9*pi*x*sin(2.827433388230814*x*y) + 4.0*pi*cos(3.1415926535897932*y))*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0) + (-0.1*pi*x*sin(3.9269908169872415*x*y) -0.15*pi*sin(3.1415926535897932*y))*(2450.0*(0.0571428571428571*sin(5.235987755982989*x) -0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1)^2 + 4050.0*(0.0444444444444444*sin(3.1415926535897932*y) -0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1)^2 + 2.5*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0))*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) - 11.0*cos(2.827433388230814*x*y) +90.0) - 35.0*(0.1*pi*x*sin(3.9269908169872415*x*y) +0.15*pi*sin(3.1415926535897932*y))*(0.2*pi*x*sin(3.9269908169872415*x*y) + 0.3*pi*sin(3.1415926535897932*y))*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0)^3 - 70.0*(0.1*pi*x*sin(3.9269908169872415*x*y) +0.15*pi*sin(3.1415926535897932*y))*(-18750.0*pi*x*cos(2.3561944901923449*x*y) + 25000.0*pi*cos(3.9269908169872415*y))/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0)^2 + (-18750.0*pi*x*cos(2.3561944901923449*x*y) +25000.0*pi*cos(3.9269908169872415*y))*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) -11.0*cos(2.827433388230814*x*y) + 90.0) + (-4.2*pi*y*sin(1.8849555921538759*x*y) + 6.66666666666667*pi*cos(5.235987755982989*x))*(2450.0*(0.0571428571428571*sin(5.235987755982989*x) - 0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1)^2 + 4050.0*(0.0444444444444444*sin(3.1415926535897932*y) - 0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1)^2 + 2.5*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0) - (-4.2*pi*y*sin(1.8849555921538759*x*y) +6.66666666666667*pi*cos(5.235987755982989*x))*(-66.0*pi*x*sin(2.827433388230814*x*y) - 56.0*pi*y*sin(1.8849555921538759*x*y) + 88.8888888888889*pi*cos(5.235987755982989*x) - 26.6666666666667*pi*cos(3.1415926535897932*y)) + (-4.2*pi*y*sin(1.8849555921538759*x*y) + 6.66666666666667*pi*cos(5.235987755982989*x))*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0) - (9.9*pi*y*sin(2.827433388230814*x*y) +30.0*pi*sin(4.7123889803846899*x))*(-42.0*pi*x*sin(1.8849555921538759*x*y) + 99.0*pi*y*sin(2.827433388230814*x*y) + 300.0*pi*sin(4.7123889803846899*x) + 180.0*pi*sin(4.7123889803846899*y)) + (-0.1*pi*y*sin(3.9269908169872415*x*y) + 0.075*pi*cos(2.3561944901923449*x))*(2450.0*(0.0571428571428571*sin(5.235987755982989*x) -0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1)^2 + 4050.0*(0.0444444444444444*sin(3.1415926535897932*y) -0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1)^2 + 2.5*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0))*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) +70.0) - 35.0*(0.1*pi*y*sin(3.9269908169872415*x*y) -0.075*pi*cos(2.3561944901923449*x))*(0.2*pi*y*sin(3.9269908169872415*x*y) - 0.15*pi*cos(2.3561944901923449*x))*(20000.0*sin(3.9269908169872415*y) - 25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0)^3 - 70.0*(0.1*pi*y*sin(3.9269908169872415*x*y) -0.075*pi*cos(2.3561944901923449*x))*(-18750.0*pi*y*cos(2.3561944901923449*x*y) + 30000.0*pi*sin(3.1415926535897932*x))/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) +1.0)^2 + (-18750.0*pi*y*cos(2.3561944901923449*x*y) +30000.0*pi*sin(3.1415926535897932*x))*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) +7.0*cos(1.8849555921538759*x*y) + 70.0) - 35.0*(14062.5*pi^2*x^2*sin(2.3561944901923449*x*y) - 31250.0*pi^2*sin(3.9269908169872415*y))/(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0) - 35.0*(0.125*pi^2*x^2*cos(3.9269908169872415*x*y) + 0.15*pi^2*cos(3.1415926535897932*y))*(20000.0*sin(3.9269908169872415*y) -25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)^2 - 35.0*(14062.5*pi^2*y^2*sin(2.3561944901923449*x*y) + 30000.0*pi^2*cos(3.1415926535897932*x))/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0) - 35.0*(0.125*pi^2*y^2*cos(3.9269908169872415*x*y) + 0.05625*pi^2*sin(2.3561944901923449*x))*(20000.0*sin(3.9269908169872415*y) -25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)^2 + (2450.0*(-0.12*pi*x*sin(1.8849555921538759*x*y) + 0.514285714285714*pi*sin(4.7123889803846899*y))*(0.0571428571428571*sin(5.235987755982989*x) - 0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1) + 4050.0*(0.22*pi*x*sin(2.827433388230814*x*y) +0.0888888888888889*pi*cos(3.1415926535897932*y))*(0.0444444444444444*sin(3.1415926535897932*y) -0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1) + 2.5*(0.1*pi*x*sin(3.9269908169872415*x*y) + 0.15*pi*sin(3.1415926535897932*y))*(20000.0*sin(3.9269908169872415*y) -25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)^2 + 2.5*(-18750.0*pi*x*cos(2.3561944901923449*x*y) + 25000.0*pi*cos(3.9269908169872415*y))/(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) -11.0*cos(2.827433388230814*x*y) + 90.0) + (2450.0*(-0.12*pi*y*sin(1.8849555921538759*x*y) + 0.19047619047619*pi*cos(5.235987755982989*x))*(0.0571428571428571*sin(5.235987755982989*x) - 0.171428571428571*cos(4.7123889803846899*y) + 0.1*cos(1.8849555921538759*x*y) + 1) + 4050.0*(0.22*pi*y*sin(2.827433388230814*x*y) +0.666666666666667*pi*sin(4.7123889803846899*x))*(0.0444444444444444*sin(3.1415926535897932*y) -0.222222222222222*cos(4.7123889803846899*x) -0.122222222222222*cos(2.827433388230814*x*y) + 1) + 2.5*(0.1*pi*y*sin(3.9269908169872415*x*y) - 0.075*pi*cos(2.3561944901923449*x))*(20000.0*sin(3.9269908169872415*y) -25000.0*sin(2.3561944901923449*x*y) - 30000.0*cos(3.1415926535897932*x) + 100000.0)/(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)^2 + 2.5*(-18750.0*pi*y*cos(2.3561944901923449*x*y) + 30000.0*pi*sin(3.1415926535897932*x))/(0.1*sin(2.3561944901923449*x) +0.15*cos(3.1415926535897932*y) + 0.08*cos(3.9269908169872415*x*y) + 1.0))*(0.1*sin(2.3561944901923449*x) + 0.15*cos(3.1415926535897932*y) +0.08*cos(3.9269908169872415*x*y) + 1.0)*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) +7.0*cos(1.8849555921538759*x*y) + 70.0) - (-25.2*pi^2*x^2*cos(1.8849555921538759*x*y) + 89.1*pi^2*x*y*cos(2.827433388230814*x*y) + 99.0*pi*sin(2.827433388230814*x*y) + 270.0*pi^2*cos(4.7123889803846899*y))*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) +7.0*cos(1.8849555921538759*x*y) + 70.0) - (118.8*pi^2*x^2*cos(2.827433388230814*x*y) + 16.8*pi^2*x*y*cos(1.8849555921538759*x*y) - 53.3333333333333*pi^2*sin(3.1415926535897932*y) + 28.0*pi*sin(1.8849555921538759*x*y))*(4.0*sin(3.1415926535897932*y) - 20.0*cos(4.7123889803846899*x) - 11.0*cos(2.827433388230814*x*y) +90.0) - (-25.2*pi^2*x*y*cos(1.8849555921538759*x*y) +89.1*pi^2*y^2*cos(2.827433388230814*x*y) - 42.0*pi*sin(1.8849555921538759*x*y) + 450.0*pi^2*cos(4.7123889803846899*x))*(4.0*sin(3.1415926535897932*y) -20.0*cos(4.7123889803846899*x) - 11.0*cos(2.827433388230814*x*y) + 90.0) - (-59.4*pi^2*x*y*cos(2.827433388230814*x*y) - 33.6*pi^2*y^2*cos(1.8849555921538759*x*y) - 148.148148148148*pi^2*sin(5.235987755982989*x) - 66.0*pi*sin(2.827433388230814*x*y))*(4.0*sin(5.235987755982989*x) - 12.0*cos(4.7123889803846899*y) + 7.0*cos(1.8849555921538759*x*y) +70.0)



   src.mass = fmass
   src.momentum_x = fxmom
   src.momentum_y = fymom
   src.momentum_z = 0.0
   src.total_energy = fe
   return src
end