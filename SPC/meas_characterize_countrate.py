
import numpy as np
import math
import time
from helpers import download_oscope_data as dod
from helpers import siggen_functions
from helpers import set_multim2636A_voltage as smv
from helpers import oscope_functions


def run(mi, measdir, smu_data, acq_delay, voltages, CRmeas_type):

    # set voltages
    for val in voltages:
        smv.send_scpi("%s" % val)

    # program some basic overall siggen settings
    if CRmeas_type == "comp":
        vhi = 3
        vlo = 0
        # note: beyond 4.9 MHz, trigger output from siggen is divided down (see AFG quick start manual)
        frequency = (2, 7, 60)
    elif CRmeas_type == "clockgen":
        vhi = 5
        vlo = 0
        frequency = (4, 7, 50)
    query = [
        ["OUTPUT1:STATE OFF"],
        ["OUTPUT2:STATE OFF"],
        ["SOURCE1:VOLTAGE:UNIT VPP"],
        ["SOURCE1:FUNCTION:SHAPE SQUARE"],
        ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:HIGH %fV" % vhi],
        ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:LOW  %fV" % vlo],
        ["OUTPUT1:STATE ON"],
    ]
    siggen_functions.send_query(query)

    # run count rate loop
    dircnt = 1  # variable used to create separate folders for each meas point
    for F in np.logspace(frequency[0], frequency[1], num=frequency[2], endpoint=True, base=10):

        # change the siggen frequency
        query = [
            ["SOURCE1:FREQUENCY %f" % F]
        ]
        siggen_functions.send_query(query)

        # autoset doesnt work well for clockgen, but works great for comparator
        if CRmeas_type == "comp":
            # change the time window and record length for horizontal acq
            mi.write('AUTOSET EXECUTE')
            # unfortunately, OPC and BUSY dont work here, so just hard-coded a sleep...
            time.sleep(4.5)

        # fix for: sometimes autoset chooses the wrong horizontal div scale
        # round up to nearest whole frequency
        Fpower = math.floor(math.log10(F))
        F = F / 10 ** Fpower
        F = math.ceil(F)
        F = F * 10 ** Fpower
        Fdiv = 1/F * 2.5
        # set the oscope to at least this division step
        mi.write("HORIZONTAL:MODE:SCALE %0.12f" % Fdiv)
        # give the scope enough time to set the new scale
        time.sleep(2)

        # make sure the record length is 10k
        oscope_functions.set_recordlength(mi, 10000)
        # acquire the data
        if acq_delay == 0:
            time.sleep(2)  # wait a few seconds to let everything settle
        else:
            oscope_functions.acq_delayer(mi, acq_delay)
        measdir2 = "%s/meas%04d" % (measdir, dircnt)
        dod.run(mi, measdir2, smu_data, "false")

        dircnt += 1







