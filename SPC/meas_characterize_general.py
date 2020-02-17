
import os
import subprocess
import time
import re
from helpers import set_multim2636A_voltage as smv
import visa
import meas_characterize_amp
import meas_characterize_comp


# ---- User-defined settings ---- #
SPCsetup_path = "../SPCsetup1"
scopeip = "192.168.66.85"
unixdir = "/mnt/ArrayData/MasdaX/2018-01/measurements"
chipID = "29D1-5_WP5_1-1-1_amp3st1bw"
runcon = "custom step wave 200 Hz 130 mVpp with 1:10 voltage divider, effective 13 mVpp"
#runcon = "ramp 0-3.5V 10khz, 1.8MEG 12c probe with calibrated gain of 16 (24 dB)"
notes = "second time trying upgraded python acq script on amplifier"
meas_type = "amp"
#meas_type = "comp"
#cirtype = "schmitt"
#meas_type = "clockgen"
#meas_type = "counter"

# oscilloscope math channel settings
# FORMAT:  math<#> = (ch_num, command, num_samples)
math_ch = (2, "AVG(CH2)", 300)
# TODO: consider moving this value into each respective measurement (amp, comp, etc)
acq_delay = 400  # purposely waiting an extra 100 acq


# ---- Begin measurement script ---- #
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


# make the working directory
dtag = time.strftime("%Y%m%dT%H%M%S", time.localtime())
# patch for Mac
# probably will never run on Mac anymore... delete?
if not os.path.exists(unixdir):
    unixdir = re.sub("mnt", "Volumes", unixdir)
measdir = "%s/%s_%s" % (unixdir, dtag, chipID)
os.mkdir(measdir)

# write the SPCsetup[12] information
smu_data = subprocess.check_output(
    "grep DFILEPREFIX %s | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'" % SPCsetup_path, shell=True)
hostname = subprocess.check_output(
    "grep SMUHOST %s | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'" % SPCsetup_path, shell=True)
smu_data = re.sub("\$\(hostname\)_", hostname.decode('utf-8'), smu_data.decode('utf-8'))
smu_data = smu_data.rstrip()  # take off newline
idfh = open("%s/id.txt" % measdir, 'w')
idfh.write("directory_prefix: %s" % smu_data)
idfh.write("\nchip_id: %s" % chipID)
idfh.write("\nrun_conditions: %s" % runcon)
idfh.write("\nnotes: %s" % notes)
# TODO: make this math-setting loop dynamic, currently hard-coded for math2 channel
idfh.write("\nmath2 avg: %d" % math_ch[2])
idfh.write("\nacq_delay: %d" % acq_delay)
idfh.close()

# Set up the default voltages for vcc and gnd
#smv.send_scpi("v1(8)")
#smv.send_scpi("v2(0)")

# connect to the oscilloscope and set up the math channel(s)
rm = visa.ResourceManager('@py')
mi = rm.open_resource("TCPIP::" + scopeip + "::INSTR")
# TODO: make this math-setting loop dynamic, currently hard-coded for math2 channel
mi.write("MATH%s:DEF \"%s\"" % (math_ch[0], math_ch[1]))
mi.write("MATH%s:NUMAVG %s" % (math_ch[0], math_ch[2]))
# TODO: auto turn-on all channels and math
# TODO: auto-set sig-gen
# TODO: auto-set horiz and vert?

if meas_type == "amp":
    # TODO: simplify function variable inputs?
    meas_characterize_amp.run(mi, measdir, smu_data, acq_delay, "high")
elif meas_type == "comp":
    meas_characterize_comp.run(mi, measdir, smu_data, acq_delay, cirtype)
elif meas_type == "clockgen":
    meas_characterize_clockgen.run(mi, measdir, smu_data)
elif meas_type == "counter":
    meas_characterize_counter.run(mi, measdir, smu_data)
else:
    print("Error: Invalid meas_type specified")

# TODO: send message to notify loop is done
print("Measurement script done!")
