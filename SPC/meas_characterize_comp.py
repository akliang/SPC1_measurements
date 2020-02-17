
import numpy as np
import time
from helpers import download_oscope_data as dod
from helpers import siggen_functions
from helpers import set_multim2636A_voltage as smv
from helpers import acq_delayer


def run(mi, measdir, smu_data, acq_delay, cirtype):

    if cirtype == "schmitt":
        vhi = 3.5
        vlo = 0
        vbias = (-1, 3.5, 19)
        vthresh = (-1, 4, 6)
    else:
        vhi = 3.5
        vlo = 0
        vbias = (-0.5, 2.5, 13)
        vthresh = (1, 5, 5)

    smv.send_scpi("v1(0)")
    smv.send_scpi("v2(0)")
    smv.send_scpi("v3(0)")
    smv.send_scpi("v4(0)")
    print("[Pre-run calibration] Vcc supplies set to 0 V, zero probe currents before starting measurement.")
    input("Press ENTER to continue...")
    smv.send_scpi("v1(8)")
    smv.send_scpi("v3(8)")
    print("Setting Vcc supplies back to 8 V.")

    # program the siggen settings
    # TODO: add frequency (typically 10 kHz) to siggen setting
    # TODO: offset isnt working correctly?
    query = [
        ["OUTPUT1:STATE OFF"],
        ["OUTPUT2:STATE OFF"],
        ["SOURCE1:VOLTAGE:UNIT VPP"],
        ["SOURCE1:FUNCTION:SHAPE RAMP"],
        ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:HIGH %fV" % vhi],
        ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:LOW  %fV" % vlo],
        ["OUTPUT1:STATE ON"],
    ]
    siggen_functions.send_query(query)

    dircnt = 1  # variable used to create separate folders for each meas point
    for P in np.linspace(vbias[0], vbias[1], num=vbias[2], endpoint=True):
        for F in np.linspace(vthresh[0], vthresh[1], num=vthresh[2], endpoint=True):

            # write the voltages to the SPCpytrigger file
            smv.send_scpi("v5(%f)" % P)
            smv.send_scpi("v6(%f)" % F)

            if acq_delay == 0:
                time.sleep(2)  # wait a few seconds to let everything settle
            else:
                acq_delayer.run(mi, acq_delay)
            measdir2 = "%s/meas%04d" % (measdir, dircnt)
            dod.run(mi, measdir2, smu_data, "false")

            dircnt += 1







