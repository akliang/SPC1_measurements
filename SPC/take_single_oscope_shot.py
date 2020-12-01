

import time
import subprocess
import re
import visa
from helpers import download_oscope_data as dod
from helpers import oscope_functions


def run():

    chipID = "29D1-5_WP6_3-2-5_DiffTFT"
    notes = "counter performance with in Vpp 6.5V at ___ kHz"

    # create mi handle
    scopeip = "192.168.66.85"
    rm = visa.ResourceManager('@py')
    mi = rm.open_resource("TCPIP::" + scopeip + "::INSTR")

    # create measdir handle
    dtag = time.strftime("%Y%m%dT%H%M%S", time.localtime())
    measdir = "/mnt/ArrayData/MasdaX/2018-01/measurements/single_shots/%s" % dtag

    # create smu_data handle
    SPCsetup_path = "../SPCsetup1"
    smu_data = subprocess.check_output(
        "grep DFILEPREFIX %s | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'" % SPCsetup_path, shell=True)
    hostname = subprocess.check_output(
        "grep SMUHOST %s | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'" % SPCsetup_path, shell=True)
    smu_data = re.sub("\$\(hostname\)_", hostname.decode('utf-8'), smu_data.decode('utf-8'))
    smu_data = smu_data.rstrip()  # take off newline

    #oscope_functions.acq_delayer(mi, 400)
    dod.run(mi, measdir, smu_data, "false")

    # write notes files to measdir
    idfh = open("%s/id.txt" % measdir, 'w')
    idfh.write("\nchipID: %s" % chipID)
    idfh.write("\nnotes: %s" % notes)
    idfh.close()







