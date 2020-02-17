
from helpers import set_multim2636A_voltage as smv
from helpers import download_oscope_data as dod
import time
import numpy as np
from helpers import acq_delayer


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
                if acq_delay == 0:
                    time.sleep(2)  # wait a few seconds to let everything settle
                else:
                    acq_delayer.run(mi, acq_delay)
                measdir2 = "%s/meas%04d" % (measdir, dircnt)
                dod.run(mi, measdir2, smu_data, "false")


                dircnt += 1


