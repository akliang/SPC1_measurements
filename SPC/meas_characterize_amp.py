
import numpy as np
import os
import time
import subprocess
import re
from helpers import download_oscope_data
from helpers import set_multim2636A_voltage as smv
import hw_settings as hwset
import visa

# hi-res settings
m2b_vals = (-1.5, 4, 61)
m3b_vals = (1, 1, 1)
m4b_vals = (-1.5, 4, 25)
# low-res settings
#m2b_vals = (0.5, 2.5, 3)
#m3b_vals = (1, 1, 1)
#m4b_vals = (0, 1, 3)
chipID = "29D1-8_WP5_5-1-2_amp3st1bw"
runcon = "custom step wave 200 Hz 130 mVpp with 1:10 voltage divider, effective 13 mVpp, fixed all impedances (high-Z)"
notes = "probe12C in high-Z = 1:10 atten (10x factor applied at scope); probes are DC coupled with 20 MHz BW limit; performing wider m2b and m4b sweep"

# oscilloscope math channel settings
# math<#> = (ch#, command, #samples)
math_ch = (2, "AVG(CH2)", 300)
# TODO: auto-set horiz and vert?

# sanity check to make sure everything is running
print("""
Checklist before starting:
- Is "./multim_2636A_unified.sh SPCsetup1" is running?
- Is eve proxy running? (ssh -D 9998 eve)
- Did you mount psidata on the oscilloscope?
- Did you update chipID, runcon, and notes?
- Are all the desired channels and maths turned on? (eg, ch1 ch2 math1 math2)
- Are all impedances set correctly?  Atten factor applied to scope?
""")
input("Press ENTER to continue...")
# TODO: auto turn-on all channels and math
# TODO: auto-set sig-gen

# make the working directory
unixdir = "/mnt/ArrayData/MasdaX/2018-01/measurements"
# patch for Mac
if not os.path.exists(unixdir):
    unixdir = re.sub("mnt", "Volumes", unixdir)
dtag = time.strftime("%Y%m%dT%H%M%S", time.localtime())
utime = int(time.time())
workdir = "%s/%s" % (unixdir, dtag)
os.mkdir(workdir)

# write the SPCsetup[12] information
smu_data = subprocess.check_output("grep DFILEPREFIX ../SPCsetup1 | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'", shell=True)
hostname = subprocess.check_output("grep SMUHOST ../SPCsetup1 | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'", shell=True)
smu_data = re.sub("\$\(hostname\)_", hostname.decode('utf-8'), smu_data.decode('utf-8'))
smu_data = smu_data.rstrip()  # take off newline
idfh = open("%s/id.txt" % workdir, 'w')
idfh.write("directory_prefix: %s" % smu_data)
idfh.write("\nchip_id: %s" % chipID)
idfh.write("\nrun_conditions: %s" % runcon)
idfh.write("\nnotes: %s" % notes)
idfh.write("\nmath2 avg: %f" % math_ch[2])
idfh.close()

# Set up the default voltages for vcc and gnd
smv.send_scpi("v1(8)")
smv.send_scpi("v2(0)")

# connect to the oscilloscope and set up the math channel(s)
rm = visa.ResourceManager('@py')
mi = rm.open_resource("TCPIP::" + hwset.scopeip + "::INSTR")
mi.write("MATH%s:DEF \"%s\"" % (math_ch[0], math_ch[1]))
mi.write("MATH%s:NUMAVG %s" % (math_ch[0], math_ch[2]))

dircnt = 1  # variable used to create separate folders for each meas point
for P in np.linspace(m3b_vals[0], m3b_vals[1], num=m3b_vals[2], endpoint=True):
    for F in np.linspace(m2b_vals[0], m2b_vals[1], num=m2b_vals[2], endpoint=True):
        for G in np.linspace(m4b_vals[0], m4b_vals[1], num=m4b_vals[2], endpoint=True):

            # write the voltages to the SPCpytrigger file
            smv.send_scpi("v3(%f)" % F)
            smv.send_scpi("v4(%f)" % P)
            smv.send_scpi("v5(%f)" % G)

            # perform actions after SMU consumes the file
            print("  Waiting for %s acquisitions before saving file" % math_ch[2])
            acqnow = mi.query("ACQ:NUMACQ?")
            acqstart = int(acqnow)
            while int(acqnow) < (acqstart + math_ch[2]):
                acqnow = mi.query("ACQ:NUMACQ?")
                time.sleep(2)
            print("  Downloading oscilloscope data")
            # make the directory to store the oscilloscope data
            measdir = "%s/meas%04d" % (workdir, dircnt)
            os.mkdir(measdir)
            download_oscope_data.run(measdir, smu_data)

            # send the measdir over for pre-processing
            # TODO: set this flag

            dircnt += 1

print("Voltage loop finished!")
# TODO: send message to notify loop is done
