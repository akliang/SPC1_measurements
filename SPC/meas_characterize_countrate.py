
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
        recordlength = 50000
    elif CRmeas_type == "clockgen":
        vhi = 5
        vlo = 0
        frequency = (4, 6, 50)
        recordlength = 50000
    elif CRmeas_type == "counter":
        # phi setting for 29D1-5_WP6_3-2-5_diffTFT
        vhi = 0.5
        vlo = -2
        frequency = (4, 6.5, 50)
        recordlength = 1000
        mi.write("TRIGGER:A:EDGE:SOURCE CH1")
        mi.write("ACQUIRE:STOPAFTER SEQUENCE")
        mi.write("ACQUIRE:STATE 1")

    if CRmeas_type is not "counter":
        query = [
            ["OUTPUT1:STATE OFF"],
            ["OUTPUT2:STATE OFF"],
            ["SOURCE1:VOLTAGE:UNIT VPP"],
            ["SOURCE1:FUNCTION:SHAPE SQUARE"],
            ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:HIGH %fV" % vhi],
            ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:LOW  %fV" % vlo],
            ["OUTPUT1:STATE ON"],
        ]
    else:
        query = [
            ["OUTPUT1:STATE OFF"],
            ["OUTPUT2:STATE OFF"],
            ["SOURCE1:VOLTAGE:UNIT VPP"],
            ["SOURCE1:FUNCTION:SHAPE PULSE"],
            ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:HIGH %fV" % vhi],
            ["SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:LOW  %fV" % vlo],
        ]
    siggen_functions.send_query(query)

    # run count rate loop
    dircnt = 1  # variable used to create separate folders for each meas point
    for F in np.logspace(frequency[0], frequency[1], num=frequency[2], endpoint=True, base=10):
    #for F in np.linspace(95000, 105000, 40):

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
        Fdiv = 1/F * 3
        # set the oscope to at least this division step
        mi.write("HORIZONTAL:MODE:SCALE %0.12f" % Fdiv)
        # give the scope enough time to set the new scale
        time.sleep(2)

        if CRmeas_type == "counter":
            # note, this assumes in is ch4 and inbar is ch5
            smv.send_scpi("v4(0)")
            smv.send_scpi("v5(6.5)")
            siggen_functions.send_query([["OUTPUT1:STATE ON"]])
            time.sleep(2)
            siggen_functions.send_query([["OUTPUT1:STATE OFF"]])
            time.sleep(2)
            smv.send_scpi("v4(6.5)")
            smv.send_scpi("v5(0)")
            time.sleep(2)

            # set the oscope into SINGLE mode
            mi.write("ACQUIRE:STOPAFTER SEQUENCE")
            mi.write("ACQUIRE:STATE 1")
            time.sleep(2)
            siggen_functions.send_query([["OUTPUT1:STATE ON"]])
            time.sleep(2)
            siggen_functions.send_query([["OUTPUT1:STATE OFF"]])

        # make sure the record length is 50k
        # TODO: this seems to overlap with meas_characterize_general, but maybe autoset destroys the _general setting
        # leaving this line here allows CR measurement to use different recordlength than _general
        oscope_functions.set_recordlength(mi, recordlength)
        # acquire the data
        if acq_delay == 0:
            time.sleep(2)  # wait a few seconds to let everything settle
        else:
            oscope_functions.acq_delayer(mi, acq_delay)
        measdir2 = "%s/meas%04d" % (measdir, dircnt)
        dod.run(mi, measdir2, smu_data, "false")

        dircnt += 1







