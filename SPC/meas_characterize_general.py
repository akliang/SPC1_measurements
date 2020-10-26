
import os
import subprocess
import time
import re
import visa
from helpers import oscope_functions
import meas_characterize_amp
import meas_characterize_comp
import meas_characterize_countrate


# ---- User-defined settings ---- #
SPCsetup_path = "../SPCsetup1"
scopeip = "192.168.66.85"
unixdir = "/mnt/ArrayData/MasdaX/2018-01/measurements"
chipID = "29D1-5_WP6_3-2-4_7inv"

#meas_type = "amp"
#runcon = "custom step wave 200 Hz 130 mVpp with 1:10 voltage divider, effective 13 mVpp, horiz acq is 10k samples"
#notes = "added 50ohm load to siggen input to probe card, running standard comp sweep at 100 kHz"
#acq_delay = 400

#meas_type = "comp"
#cirtype = "schmitt"
#runcon = "ramp 0-4.5V 100khz, 1.8MEG 12c probe with calibrated gain of 16 (24 dB)"
#notes = "re-running standard comp sweep with high ramp max so hysteresis curve looks more symmetrical"
#acq_delay = 400
# note: to run countrate for comp, borrow the block below from clockgen

# note: there is no meas_type clockgen, but this label is here for clarity
#meas_type = "clockgen"
meas_type = "countrate"
runcon = "square 0-5V, (2x) 1.8MEG 12c probe with calibrated gain of 16 (24 dB) and 18 (25.1 dB)"
notes = "measurement of first working instance of 7inv CG design variant"
acq_delay = 50   # afraid to set this to 0, but technically it should be

# note: there is no meas_type counter, but this label is here for clarity
#meas_type = "counter"
#meas_type = "countrate"
#runcon = "(2x) 1.8MEG 12c probe with calibrated gain of 16 (24 dB) and 18 (25.1 dB); in and inbar from SMU at 0 to 6.5V, 10-percent duty cycle for phi"
#notes = "decently working diffTFT counter bit, out is full swing but outbar is slightly weak about 75-percent swing"
#acq_delay = 0

target_recordlength = 10000
# oscilloscope math channel settings
# FORMAT:  math<#> = (ch_num, command, num_samples)
math_ch = (2, "AVG(CH2)", 300)
# TODO: consider moving this value into each respective measurement (amp, comp, etc)
#acq_delay = 400  # purposely waiting an extra 100 acq


# ---- Begin measurement script ---- #
print("""
Checklist before starting:
- Is "./multim_2636A_unified.sh SPCsetup1" is running?
- Did you mount psidata on the oscilloscope?
- Did you update chipID, runcon, and notes?
- Are all the desired channels and maths turned on? (eg, ch1 ch2 math1 math2)
- Are all impedances set correctly?  Atten factor applied to scope?
- For count rate measurements, did you add this circuit to the db?
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
# TODO: hostname is probably not needed anymore since smu_data doesnt have the hostname variable in the SPCsetup1 file (it probably did in the past so the substition needed to be done here)
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
# note: trigger source is changed to CH1 whenever autoset is run
mi.write("TRIGGER:A:EDGE:SOURCE CH4")
# TODO: make this math-setting loop dynamic, currently hard-coded for math2 channel
mi.write("MATH%s:DEF \"%s\"" % (math_ch[0], math_ch[1]))
mi.write("MATH%s:NUMAVG %s" % (math_ch[0], math_ch[2]))
# make sure the record length is 10k samples
oscope_functions.set_recordlength(mi, 10000)
# TODO: auto turn-on all channels and math
# TODO: auto-set horiz and vert to right positions?

if meas_type == "amp":
    # TODO: simplify function variable inputs?
    mi.write("MATH1:DEF \"Ch1/10\"")
    meas_characterize_amp.run(mi, measdir, smu_data, acq_delay, "high")
elif meas_type == "comp":
    mi.write("MATH1:DEF \"Ch1\"")
    meas_characterize_comp.run(mi, measdir, smu_data, acq_delay, cirtype)
elif meas_type == "countrate":
    voltage_db = {
        "29D1-8_WP5_2-4-3_schmitt": ["v1(8)", "v2(0)", "v3(8)", "v4(0)", "v5(1)", "v6(3)", "comp"],
        "29D1-8_WP8_4-6-10_2SR3inv": ["v1(8)", "v2(0)", "v3(0)", "v4(0)", "v5(0)", "v6(0)", "clockgen"],
        "29D1-5_WP6_3-2-16_2SR3inv": ["v1(8)", "v2(0)", "v3(0)", "v4(0)", "v5(0)", "v6(0)", "clockgen"],
        "29D1-5_WP6_3-3-1_2SR3inv": ["v1(8)", "v2(0)", "v3(0)", "v4(0)", "v5(0)", "v6(0)", "clockgen"],
        "29D1-5_WP6_3-2-5_diffTFT": ["v1(8)", "v2(0)", "v3(-5)", "v4(0)", "v5(6.5)", "v6(0)", "counter"],
        "29D1-5_WP6_3-2-4_7inv": ["v1(8)", "v2(0)", "v3(0)", "v4(0)", "v5(0)", "v6(0)", "clockgen"],
    }
    if chipID not in voltage_db.keys():
        print("Error: no voltage data entry found for %s" % chipID)
        quit()
    else:
        voltages = voltage_db[chipID]
        CRmeas_type = voltages.pop()
    meas_characterize_countrate.run(mi, measdir, smu_data, acq_delay, voltages, CRmeas_type)
else:
    print("Error: Invalid meas_type specified")

# TODO: send message to notify loop is done
print("Measurement script done!")
