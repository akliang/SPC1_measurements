
from helpers import set_multim2636A_voltage as smv
from helpers import download_oscope_data2 as dod
import time
import numpy as np


def run(mi, measdir, smu_data, acq_delay, res_level):

    if res_level == "high":
        # hi-res settings
        m2b_vals = (-2, 4, 61)
        m3b_vals = (1, 1, 1)
        m4b_vals = (-2, 4, 25)
    else:
        # low-res settings
        m2b_vals = (0.5, 2.5, 3)
        m3b_vals = (1, 1, 1)
        m4b_vals = (0, 1, 3)

    dircnt = 1  # variable used to create separate folders for each meas point
    for P in np.linspace(m3b_vals[0], m3b_vals[1], num=m3b_vals[2], endpoint=True):
        for F in np.linspace(m2b_vals[0], m2b_vals[1], num=m2b_vals[2], endpoint=True):
            for G in np.linspace(m4b_vals[0], m4b_vals[1], num=m4b_vals[2], endpoint=True):

                # write the voltages to the SPCpytrigger file
                smv.send_scpi("v3(%f)" % F)
                smv.send_scpi("v4(%f)" % P)
                smv.send_scpi("v5(%f)" % G)

                # perform actions after SMU consumes the file
                print("  Waiting for %s acquisitions before saving file" % acq_delay)
                acqnow = mi.query("ACQ:NUMACQ?")
                acqstart = int(acqnow)
                while int(acqnow) < (acqstart + acq_delay):
                    acqnow = mi.query("ACQ:NUMACQ?")
                    time.sleep(2)
                # make the directory to store the oscilloscope data
                measdir2 = "%s/meas%04d" % (measdir, dircnt)
                dod.run(mi, measdir2, smu_data)

                dircnt += 1


