#!/usr/bin/env python
#
# This Python script is used to coordinate the
# execution of several grid refinements of
# a Method of Manufactured Solutions case such
# that an observed order of accuracy can be
# extracted. The user can configure the details
# of the case in a supplied Python file.
# For example, if the configuration file is
# called config.py, then this script may launched
# from the command line as:
#
# > python run-verification-test.py config.py
#
# Author: Rowan J. Gollan
# Date: Jun-2015
# Place: Tucson, Arizona
#
# Modified: 01/02/2021, D. Bond 

import os
import shutil
import numpy as np
import pylab as plt
import matplotlib as mpl
import sys
from sympy import *
import string
from string import Template

def mms_sources():

    t, x, y, z, rho, u, v, w, p, nuhat = symbols('t, x y z rho u v w p nuhat')

    if 0: 
        # top-hat distribution
        g = 20.0
        w = 0.25

        cx = 0.5
        cy = 0.5
        cz = 0.5

        r, s = symbols('r s')
        r = sqrt((x-cx)**2 + (y-cy)**2 + (z-cz)**2)
        s = 0.5*(tanh(g*(r + w)) - tanh(g*(r - w)))

        rho = s + 1
        u = 100.0
        v = -50.0
        w = 10.0
        p = 1e5
        nuhat = s + 1
        tke = 1000.0
        omega = 150.0

    else:

        rho0=1.0; rhox=0.15; rhoy=-0.1; rhoz=0.1; rhoxy=0.08; rhoyz=0.05; rhozx=0.12; arhox=0.75; arhoy=0.45; arhoz=0.8; arhoxy=0.65; arhoyz=0.75; arhozx=0.5
        u0=70.0; ux=7.0; uy=-15.0; uz=-10.0; uxy=7.0; uyz=4.0; uzx=-4.0; aux=0.5; auy=0.85; auz=0.4; auxy=0.6; auyz=0.8; auzx=0.9
        v0=90.0; vx=-5.0; vy=10.0; vz=5.0; vxy=-11.0; vyz=-5.0; vzx=5.0; avx=0.8; avy=0.8; avz=0.5; avxy=0.9; avyz=0.4; avzx=0.6
        w0=80.0; wx=-10.0; wy=10.0; wz=12.0; wxy=-12.0; wyz=11.0; wzx=5.0; awx=0.85; awy=0.9; awz=0.5; awxy=0.4; awyz=0.8; awzx=0.75
        p0=1.0e5; px=0.2e5; py=0.5e5; pz=0.2e5; pxy=-0.25e5; pyz=-0.1e5; pzx=0.1e5; apx=0.4; apy=0.45; apz=0.85; apxy=0.75; apyz=0.7; apzx=0.8
        nuhat0=1.0; nuhatx=0.240; nuhaty=-0.30; nuhatz=0.80; nuhatxy=0.75; nuhatyz=0.50; nuhatzx=-0.60; anuhatx=0.35; anuhaty=0.4; anuhatz=0.8; anuhatxy=0.5; anuhatyz=0.25; anuhatzx=0.6
        tke0=780.0; tkex=160.0; tkey=-120.0; tkez=80.0; tkexy=80.0; tkeyz=60.0; tkezx=-70.0; atkex=0.65; atkey=0.7; atkez=0.8; atkexy=0.8; atkeyz=0.85; atkezx=0.6
        omega0=150.0; omegax=-30.0; omegay=22.5; omegaz=20.0; omegaxy=40.0; omegayz=-15.0; omegazx=25.0; a_omegax=0.75; a_omegay=0.875; a_omegaz=0.65; a_omegaxy=0.6; a_omegayz=0.75; a_omegazx=0.8
        
        S = 1.0

        rho = rho0 + S*rhox*cos(arhox*pi*x/L) + S*rhoy*sin(arhoy*pi*y/L) + \
            S*rhoz*sin(arhoz*pi*z/L) + S*rhoxy*cos(arhoxy*pi*x*y/(L*L)) + \
            S*rhozx*sin(arhozx*pi*x*z/(L*L)) + S*rhoyz*cos(arhoyz*pi*y*z/(L*L))

        u =  u0 + S*ux*sin(aux*pi*x/L) + S*uy*cos(auy*pi*y/L) + S*uz*cos(auz*pi*z/L) + \
            S*uxy*cos(auxy*pi*x*y/(L*L)) + S*uzx*sin(auzx*pi*x*z/(L*L)) + \
            S*uyz*cos(auyz*pi*y*z/(L*L))

        v =  v0 + S*vx*sin(avx*pi*x/L) + S*vy*cos(avy*pi*y/L) + S*vz*cos(avz*pi*z/L) + \
            S*vxy*cos(avxy*pi*x*y/(L*L)) + S*vzx*sin(avzx*pi*x*z/(L*L)) + \
            S*vyz*cos(avyz*pi*y*z/(L*L))


        w =  w0 + S*wx*cos(awx*pi*x/L) + S*wy*sin(awy*pi*y/L) + S*wz*cos(awz*pi*z/L) + \
            S*wxy*sin(awxy*pi*x*y/(L*L)) + S*wzx*sin(awzx*pi*x*z/(L*L)) + \
            S*wyz*cos(awyz*pi*y*z/(L*L))


        p =  p0 + S*px*cos(apx*pi*x/L) + S*py*cos(apy*pi*y/L) +  S*pz*sin(apz*pi*z/L) + \
            S*pxy*cos(apxy*pi*x*y/(L*L)) + S*pzx*sin(apzx*pi*x*z/(L*L)) + \
            S*pyz*cos(apyz*pi*y*z/(L*L))

        nuhat =  nuhat0 + nuhatx*cos(anuhatx*pi*x/L) + nuhaty*cos(anuhaty*pi*y/L) + nuhatz*sin(anuhatz*pi*z/L) + \
            nuhatxy*cos(anuhatxy*pi*x*y/(L*L)) + nuhatyz*cos(anuhatyz*pi*y*z/(L*L)) + nuhatzx*sin(anuhatzx*pi*x*z/(L*L))

        tke =  tke0 + tkex*cos(atkex*pi*x/L) + tkey*cos(atkey*pi*y/L) + tkez*sin(atkez*pi*z/L) + tkexy*cos(atkexy*pi*x*y/(L*L)) + \
            + tkeyz*cos(atkeyz*pi*y*z/(L*L)) + tkezx*sin(atkezx*pi*x*z/(L*L));
        omega = omega0 + omegax*cos(a_omegax*pi*x/L) + omegay*cos(a_omegay*pi*y/L) + omegaz*sin(a_omegay*pi*z/L) + omegaxy*cos(a_omegaxy*pi*x*y/(L*L)) + \
            + omegayz*cos(a_omegayz*pi*y*z/(L*L)) + omegazx*sin(a_omegazx*pi*x*z/(L*L));

    # Thermodynamic behvaiour, equation of state and energy equation
    e, T, et, ht = symbols('e T et ht')
    e = p/rho/(gamma-1)
    T = e/Cv
    et = e + u*u/2 + v*v/2 + w*w/2
    ht = et + p/rho

    fnuhat = symbols('fnuhat')

    cv1 = 7.1
    cv2 = 0.7
    cv3 = 0.9
    cb1 = 0.1355
    cb2 = 0.622
    ct3 = 1.2
    ct4 = 0.5
    kappa = 0.41
    sigma = 2.0/3.0
    cw2 = 0.3
    cw3 = 2.0

    nu, chi = symbols('chi nu')
    nu = mu/rho
    chi = nuhat/nu

    ft2, fv1, fv2 = symbols('ft2 fv1 fv2')

    ft2 = ct3*exp(-ct4*chi**2)
    fv1 = chi**3/(chi**3 + cv1**3)
    fv2 = 1 - chi/(1+chi*fv1)


    vel, axis, Wij, Omega = symbols('vel axis Wij Omega')
    vel = [u,v,w]
    axis = [x,y,z]
    Omega = 0
    for i in range(3):
        for j in range(3):
            Wij = 0.5*(diff(vel[i],axis[j]) - diff(vel[j],axis[i]))
            Omega += Wij*Wij

    Omega = sqrt(2*Omega)

    S_bar, S_hat = symbols('S_bar S_hat')

    S_bar = nuhat/(kappa**2*wall_distance**2)*fv2

    S_hat = Omega + S_bar

    # S_hat = Piecewise(
    #     (Omega + S_bar, S_bar >= -cv2*Omega),
    #     (Omega + (Omega*(cv2**2*Omega+cv3*S_bar))/((cv3-2*cv2)*Omega-S_bar), S_bar < -cv2*Omega)
    # )

    cw1, r, g, fw = symbols('cw1 r g fw')

    cw1 = cb1/kappa**2 + (1.0 + cb1)/sigma
    r = Min(nuhat/(S_hat*kappa**2*wall_distance**2),10.0)
    g = r + cw2*(r**6 - r)
    fw = g*((1+cw3**6)/(g**6 + cw3**6))**(Rational(1,6))

    P, D = symbols('P D')

    P = cb1*(1 - ft2)*S_hat*nuhat
    D = (cw1*fw - cb1/kappa**2*ft2)*(nuhat/wall_distance)**2

    mu_t, k_t = symbols('mu_t k_t')

    mu_t = rho*nuhat*fv1
    k_t = Cp*mu_t/PrT

    S = symbols('S')

    S = 0
    S += rho*(P - D) 
    S += (1/sigma)*(diff(rho*(nu + nuhat)*diff(nuhat,x),x) + diff(rho*(nu + nuhat)*diff(nuhat,y),y) + diff(rho*(nu + nuhat)*diff(nuhat,z),z))
    S += (cb2/sigma)*rho*(diff(nuhat,x)**2 + diff(nuhat,y)**2 + diff(nuhat,z)**2)

    fnuhat = diff(rho*nuhat, t) + diff(rho*nuhat*u, x) + diff(rho*nuhat*v, y) + diff(rho*nuhat*w, z) - S

    # Laminar and turbulent heat flux terms
    qlx, qly, qlz, qtx, qty, qtz = symbols('qlx qly qlz qtx qty qtz')
    qlx = -k*diff(T, x)
    qly = -k*diff(T, y)
    qlz = -k*diff(T, z)
    qtx = -k_t*diff(T, x)
    qty = -k_t*diff(T, y)
    qtz = -k_t*diff(T, z)

    # Laminar stress tensor
    txx, tyy, tzz, txy, tyz, tzx = symbols('txx tyy tzz txy tyz tzx')
    txx = 2./3*mu*(2*diff(u, x) - diff(v, y) - diff(w, z))
    tyy = 2./3*mu*(2*diff(v, y) - diff(u, x) - diff(w, z))
    tzz = 2./3*mu*(2*diff(w, z) - diff(u, x) - diff(v, y))
    txy = mu*(diff(u, y) + diff(v, x))
    tyz = mu*(diff(w, y) + diff(v, z))
    tzx = mu*(diff(u, z) + diff(w, x))

    # Turbulent stress tensor
    tauxx, tauyy, tauzz, tauxy, tauyz, tauzx = symbols('tauxx tauyy tauzz tauxy tauyz tauzx')
    tauxx = 2./3*mu_t*(2*diff(u, x) - diff(v, y) - diff(w, z))
    tauyy = 2./3*mu_t*(2*diff(v, y) - diff(u, x) - diff(w, z))
    tauzz = 2./3*mu_t*(2*diff(w, z) - diff(u, x) - diff(v, y))
    tauxy = mu_t*(diff(u, y) + diff(v, x))
    tauyz = mu_t*(diff(w, y) + diff(v, z))
    tauzx = mu_t*(diff(u, z) + diff(w, x))

    # equations for compressible flows in conservative form
    t, fmass, fxmom, fymom, fzmom, fe = symbols('t fmass fxmom fymom fzmom fe')
    fmass = diff(rho, t) + diff(rho*u, x) + diff(rho*v, y) + diff(rho*w, z)
    fxmom = diff(rho*u, t) + diff(rho*u*u, x) + diff(rho*u*v, y) + diff(rho*u*w, z)+ diff(p, x) - diff(txx+tauxx, x) - diff(txy+tauxy, y) - diff(tzx+tauzx, z)
    fymom = diff(rho*v, t) + diff(rho*v*u, x) + diff(rho*v*v, y) + diff(rho*v*w, z)+ diff(p, y) - diff(txy+tauxy, x) - diff(tyy+tauyy, y) - diff(tyz+tauyz, z)
    fzmom = diff(rho*w, t) + diff(rho*w*u, x) + diff(rho*w*v, y) + diff(rho*w*w, z)+ diff(p, z) - diff(tzx+tauzx, x) - diff(tyz+tauyz, y) - diff(tzz+tauzz, z)
    fe = diff(rho*(et), t) + diff(rho*u*(ht), x) + diff(rho*v*(ht), y) + diff(rho*w*(ht), z) + diff(qlx+qtx, x) + diff(qly+qty, y) + diff(qlz+qtz, z) - \
    diff(u*(txx+tauxx)+v*(txy+tauxy)+w*(tzx+tauzx), x) - diff(u*(txy+tauxy)+v*(tyy+tauyy)+w*(tyz+tauyz), y) - diff(u*(tzx+tauzx)+v*(tyz+tauyz)+w*(tzz+tauzz), z)


    funcs = {"fmass":fmass, "fxmom":fxmom, "fymom":fymom, "fzmom":fzmom, "fe":fe, "fnuhat":fnuhat,
                "rho":rho, "p":p, "T":T, "u":u, "v":v, "w":w, "mu":mu, "nuhat":nuhat, "mu_t":mu_t, "k_t":k_t}

    # save to disk
    if 0:
        for key, val in funcs.items():
                with open(key+".txt","w") as f:
                    f.write("%s='%s'"%(key,str(val)))

    return funcs

def buildRunStr(threading):
    str = ""

    str += exe_path + "e4shared --job=mms --prep\n"

    if explicit == 'true':
        str += exe_path + "e4shared --job=mms --run"
    else:
        str += exe_path + "e4-nk-shared --job=mms"

    if threading == 'single':
        str += " --max-cpus=1"
    str += "\n"

    norm_items = ','.join(norms.keys())
    str += exe_path + 'e4shared --job=mms --post --tindx-plot=last --ref-soln=ref-soln.lua  --norms="{}" > log.txt\n'.format(norm_items)
    str += exe_path + 'e4shared --job=mms --post --tindx-plot=all  --vtk-xml\n'# --ref-soln=ref-soln.lua \n' # <-- un-comment to plot error in soln

    return str

def get_enclosed(s, i):
    """
    returns the string that is enclosed by braces assuming that
    index i gives the location of the first open brace
    """
    i_ = i
    n_open = 1
    n_close = 0
    i += 1
    while n_open != n_close:
        if s[i] == "(":
            n_open += 1
        elif s[i] == ")":
            n_close += 1
        i += 1
    
    return s[i_:i], i

def generateSource(varList):
    """This function generates Lua source code based on a selection
    of the expressions defined above. The selection is defined in the
    varList. The varList is a list of tuples of the form:

    varList = [("fmass", fmass), ("fxmom", fxmom)]

    This functions returns the generated source as a string.
    """

    sourceCode = ""

    for var_name, var in varList:

        var_str = str(var)

        #convert to Lua
        var_str = var_str.replace('**', '^')
        var_str = var_str.replace('True', 'true')
        var_str = var_str.replace('Min', 'min')

        other = ""

        # handle Piecewise functions
        fname = "Piecewise"
        while fname in var_str:

            # get the stuff in the piecewise function
            i_start = var_str.find(fname)
            start_brace = i_start + len(fname)
            p, i_end = get_enclosed(var_str, start_brace)

            # split based on comma
            entries = p.split(",")

            # first and last entries have a double brace
            entries[0]  = entries[0][1::]
            entries[-1] = entries[-1][0:-1]

            # remove other unnecessary braces
            for i in range(len(entries)):
                entries[i] = entries[i].strip()
                if not i%2:
                    entries[i] = entries[i][1::]
                else:
                    entries[i] = entries[i][0:-1]

            # make a variable to hold the piecewise evaluation
            p_name = "".join(random.sample(string.ascii_letters, 5))

            var_str = var_str.replace(var_str[i_start:i_end], p_name)

            # now generate the piecewise function in lua
            pw = "\nlocal " + p_name + "\n"
            for i in range(0, len(entries), 2):
                if i == 0:
                    pw += "if(%s) then %s=%s\n"%(entries[i+1], p_name, entries[i+0])
                else:
                    pw += "elseif(%s) then %s=%s\n"%(entries[i+1], p_name, entries[i+0])
                
            pw += "end\n\n"

            other += pw

        sourceCode += other
        sourceCode += var_name +"="+ var_str + "\n\n\n\n"


    return sourceCode

def createFileFromTemplate(sourceCode, templateName, fileName):
    """Given some source code and template file, do the text substitution
    and create the real file."""
    fin = open(templateName, 'r')
    templateText = fin.read()
    fin.close()
    luaText = Template(templateText).safe_substitute(**sourceCode)

    fout = open(fileName, 'w')
    fout.write(luaText)
    fout.close()
    return

class Bunch(object):
  def __init__(self, adict):
    self.__dict__.update(adict)

def make_lua(template_folder, destination_folder, src):

    src = Bunch(src)

    taskList = [ 
        {'fName': "udf-source-terms.lua", 'tName': "udf-source-template.lua",
            'varList': [
                ("fmass", src.fmass), 
                ("fxmom", src.fxmom), 
                ("fymom", src.fymom), 
                ("fzmom", src.fzmom),
                ("fe", src.fe), 
                ("fnuhat", src.fnuhat),
            ]
        },
                 
        {'fName': "udf-bc.lua", 'tName': "udf-bc-template.lua",
            'varList': [
                ("tab.p", src.p), 
                ("tab.T", src.T), 
                ("tab.velx", src.u), 
                ("tab.vely", src.v), 
                ("tab.velz", src.w), 
                ("tab.mu_t", src.mu_t), 
                ("tab.k_t", src.k_t),
                ("tab.nuhat", src.nuhat),
            ]
        },
        
        {'fName': "ref-soln.lua", 'tName': "ref-soln-template.lua",
            'varList': [
                ("tab.rho", src.rho), 
                ("tab.p", src.p), 
                ("tab.T", src.T),
                ("tab['vel.x']", src.u), 
                ("tab['vel.y']", src.v), 
                ("tab['vel.z']", src.w),
                ("tab.mu_t", src.mu_t), 
                ("tab.k_t", src.k_t), 
                ("tab.nuhat", src.nuhat),
            ]
        },
        
        {'fName': "fill-fn.lua", 'tName': "fill-fn-template.lua",
            'varList': [
                ("rho", src.rho), 
                ("p", src.p), 
                ("T", src.T),
                ("velx", src.u), 
                ("vely", src.v), 
                ("velz", src.w),
                ("mu_t", src.mu_t), 
                ("k_t", src.k_t), 
                ("nuhat", src.nuhat),
            ]
        },

        {'fName': "gas-model.lua", 'tName': "gas-template.lua",
            'varList': [
                ("mu", src.mu), 
            ]
        },

        {'fName': "mms.lua", 'tName': "mms-template.lua",
            'varList': [
                ("config.flux_calculator", '"%s"'%fluxCalc), 
                ("config.spatial_deriv_calc", '"%s"'%derivCalc),
                ("derivLocation", '"%s"'%derivLcn),
                ("config.interpolation_order", xOrder),
                ("blocking", '"%s"'%blocking),
                ("ncells", src.ncells),
                ("explicit", explicit),
                ("config.turbulence_model", '"%s"'%turbulence_model),
            ]
        },
        ]

    for task in taskList:
        sourceCode = generateSource(task['varList'])
        createFileFromTemplate({'expressions':sourceCode}, 
            os.path.join(template_folder,task['tName']), 
            os.path.join(destination_folder,task['fName']))

def prepareCases():

    cwd = os.getcwd()

    # get the mms sources solution
    src = mms_sources()

    # make the files for each case
    for ncells in ncellsList:
        subDir = "%dx%d" % (ncells, ncells)
        try:
            os.mkdir(subDir)
        except:
            shutil.rmtree(subDir)
            os.mkdir(subDir)

        src["ncells"] = ncells

        make_lua(template_dir, subDir, src)
        
        f = open(os.path.join(subDir,'run.sh'), 'w')
        f.write(buildRunStr(threading))
        f.close()

    return

def runCases():
    cwd = os.getcwd()
    for ncells in ncellsList:
        print("========= Working on grid: %dx%d ===========" % (ncells, ncells))
        subDir = "%dx%d" % (ncells, ncells)
        os.chdir(subDir)
        cmd = "sh run.sh"
        os.system(cmd)
        os.chdir(cwd)
    return

def gatherResults():
    for key, val in norms.items():

        val["L2"] = []
        val["Linf"] = []
        val["dx"] = []

    for i, ncells in enumerate(ncellsList):
        subDir = "%dx%d" % (ncells, ncells)
        dName = subDir + "/log.txt"
        f = open(dName, 'r')

        line = f.readline()
        while line:
            for key, val in norms.items():
                if "variable= "+key in line:
                    tks = f.readline().split()
                    val["L2"].append(float(tks[3]))
                    val["Linf"].append(float(tks[5]))
                    val["dx"].append(1.0/ncells)
                    break
            line = f.readline()
        f.close()

    n_plots = len(norms)
    nr = int(np.sqrt(n_plots))
    nc = int(np.ceil(n_plots/nr))

    fig = plt.figure(figsize=(14,12))
    
    plt_id = 1
    for key, val in norms.items():

        print(key, ":", val)

        ax = fig.add_subplot(nr,nc,plt_id); plt_id += 1
        ax.set_title(key)
        ax.set_xlabel(r"$N_c$")
        ax.set_ylabel("$\epsilon$")

        x = 1/np.array(val["dx"])

        cx = (x[0:-1]+x[1::])/2.0

        r = x[1::]/x[0:-1]

        # L2
        y = np.array(val["L2"])
        if np.any(y > 0.0):
            z = np.polyfit(np.log10(x),np.log10(y),1)
            p = np.poly1d(z)
            ax.loglog(x, y, "ro")
            ax.plot(x, 10**p(np.log10(x)), "r--", alpha=0.5, label=r"$L_2\left(%0.3g\right)$"%z[0])

            p = np.log(y[0:-1]/y[1::])/np.log(r)

            sax = ax.twinx()
            sax.semilogx(cx, p, "-x")
            sax.set_ylabel("p")
            sax.set_ylim(0,1.25*p.max())

        # Linf
        y = np.array(val["Linf"])
        if np.any(y > 0.0):
            z = np.polyfit(np.log10(x),np.log10(y),1)
            p = np.poly1d(z)
            ax.loglog(x, y, "bo")
            ax.plot(x, 10**p(np.log10(x)), "b--", alpha=0.5, label=r"$L_\inf\left(%0.3g\right)$"%z[0])

        ax.legend(loc="upper center")

        ax.get_xaxis().set_major_formatter(mpl.ticker.ScalarFormatter())
        ax.xaxis.set_major_locator(mpl.ticker.FixedLocator(x))
        ax.xaxis.set_minor_locator(mpl.ticker.NullLocator())

    fig.tight_layout()

    fig.savefig("norms.pdf")

    return

if __name__ == "__main__":
    
    caseOptFile = sys.argv[1]
    exec(open(caseOptFile).read())

    norms = {n:{} for n in norm}

    if not only_analysis:
        prepareCases()
        runCases()

    gatherResults()


    
                
