  
import os
import subprocess
import re
import time
import shutil


def run(mi, measdir, dfileprefix):
    # Connects to and downloads all probe and math channels from the oscilloscope, also saves oscilloscope settings
    # note: dont forget to mountpsidata on the oscilloscope

    # 2020-01-10: Improvements from ver1:
    # - removes the max-path-char-limit (ver1 was limited to 100 char for measdir)
    #   (write all files to tmpdir, and then move to measdir later)

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

    # TODO: issue Single command to oscope

    # paths to files created by this function
    # TODO: change screenshotfile to same format as the ch1.csv below
    screenshotfile = "%s\\\\export_screenshot.png" % windir
    envfile = "%s/environment.txt" % tmpdir

    # add SMU information to env file
    envfh = open(envfile, 'w')
    smudata = ""
    smudatacnt = 0
    smudatacntthresh = 10
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

    # set correct setting values
    query = [
      ["export:filename \"%s\"" % screenshotfile],
      ["save:waveform:fileformat spreadsheetcsv"],
    ]
    for q in query:
        mi.write(q[0])

    # write some oscilloscope settings to the envfh file
    query = ["*IDN?", "ch1?", "ch2?", "ch3?", "ch4?", "math1?", "math2?", "math3?", "math4?"]
    for q in query:
        envfh.write(q + ": ")
        envfh.write(mi.query(q))

    # export data
    query = [
        ["export start"],
        ["save:waveform ch1,\"%s\\\\%s\"" % (windir, "ch1.csv")],
        ["save:waveform ch2,\"%s\\\\%s\"" % (windir, "ch2.csv")],
        ["save:waveform ch3,\"%s\\\\%s\"" % (windir, "ch3.csv")],
        ["save:waveform ch4,\"%s\\\\%s\"" % (windir, "ch4.csv")],
        ["save:waveform math1,\"%s\\\\%s\"" % (windir, "math1.csv")],
        ["save:waveform math2,\"%s\\\\%s\"" % (windir, "math2.csv")],
        ["save:waveform math3,\"%s\\\\%s\"" % (windir, "math3.csv")],
        ["save:waveform math4,\"%s\\\\%s\"" % (windir, "math4.csv")],
        ["save:waveform ch1,\"%s\\\\%s\"" % (windir, "flag_dod_done.csv")],
    ]
    for q in query:
        mi.write(q[0])

    # close the envfh file handle
    envfh.close()

    # move the files from temp folder to measdir
    print("  Saving oscope data, please wait...")
    while not os.path.exists("%s/flag_dod_done.csv" % tmpdir):
        pass
    print("  flag_dod_done.csv found, dod is done")
    # wait a moment to make absolutely sure everything finishes
    time.sleep(2)
    shutil.move(tmpdir, measdir)


