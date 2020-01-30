  
import os
import subprocess
import re
import time
import shutil


def run(mi, measdir, dfileprefix):
    # Connects to and downloads all probe and math channels from the oscilloscope, also saves oscilloscope settings
    # note: dont forget to mountpsidata on the oscilloscope

    # make sure the path doesn't already exist or else it will get overwritten by the move later
    if os.path.exists(measdir):
        print("Error: measdir(%s) already exists and would get overwritten... bailing out" % measdir)
        return

    # create the temporary directory
    dtag = time.strftime("%Y%m%dT%H%M%S", time.localtime())
    tmpdir = "/mnt/ArrayData/MasdaX/2018-01/temp/%s" % dtag
    os.mkdir(tmpdir)
    # create a windows path equivalent of tmpdir
    windir = re.sub(r"/", r"\\\\", tmpdir)
    windir = re.sub(r"^\\\\mnt\\\\ArrayData", r"P:", windir)

    utime = int(time.time())
    #utime -= 2  # grab the SMU data from a couple seconds before, to avoid writing race condition
    print("  Saving oscope data, please wait...")
    
    # Freeze the oscilloscope data
    query = [
      ["ACQUIRE:STOPAFTER SEQUENCE"],
      ["ACQUIRE:STATE 1"],
    ]
    for q in query:
        mi.write(q[0])

    # add SMU information to env file
    envfile = "%s/environment.txt" % tmpdir
    envfh = open(envfile, 'w')
    smudata = ""
    smudatacnt = 0
    smudatacntthresh = 10
    # TODO: bug?  this loop only runs once even if the grep returns nothing
    while smudata == "":
        smudatacnt += 1
        # TODO: the session path is relative... make it absolute somehow
        smudata = subprocess.check_output("grep %d ../../measurements/spc/%s_.session | head -n 1" % (utime, dfileprefix), shell=True)
        if smudatacnt > smudatacntthresh:
            print("Did not find SMU data for timepoint %d... setting to NA and moving on" % utime)
            smudata = "%d	NA" % utime
        else:
            time.sleep(1)
    envfh.write(smudata.decode('utf-8'))

    # write some oscilloscope settings to the envfh file
    query = ["*IDN?", "ch1?", "ch2?", "ch3?", "ch4?", "math1?", "math2?", "math3?", "math4?"]
    for q in query:
        envfh.write(q + ": ")
        envfh.write(mi.query(q))
    # close the envfh file handle
    envfh.close()

    # export data from the oscilloscope
    query = [
        ["export:filename \"%s\\\\%s\"" % (windir, "export_screenshot.png")],
        ["export start"],
        ["save:waveform:fileformat spreadsheetcsv"],
        ["save:waveform ch1,\"%s\\\\%s\"" % (windir, "ch1.csv")],
        ["save:waveform ch2,\"%s\\\\%s\"" % (windir, "ch2.csv")],
        ["save:waveform ch3,\"%s\\\\%s\"" % (windir, "ch3.csv")],
        ["save:waveform ch4,\"%s\\\\%s\"" % (windir, "ch4.csv")],
        ["save:waveform math1,\"%s\\\\%s\"" % (windir, "math1.csv")],
        ["save:waveform math2,\"%s\\\\%s\"" % (windir, "math2.csv")],
        ["save:waveform math3,\"%s\\\\%s\"" % (windir, "math3.csv")],
        ["save:waveform math4,\"%s\\\\%s\"" % (windir, "math4.csv")],
    ]
    for q in query:
        mi.write(q[0])

    # wait until the scope is finished
    while not int(mi.query('*OPC?')) == 1:
        time.sleep(1)

    # wait a moment to make absolutely sure everything finishes
    time.sleep(1)
    shutil.move(tmpdir, measdir)

    # Set the oscilloscope back to continuous run
    query = [
      ["ACQUIRE:STOPAFTER RUNSTOP"],
      ["ACQUIRE:STATE 1"],
    ]
    for q in query:
        mi.write(q[0])
