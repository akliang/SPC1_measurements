
import time


def run(mi, acq_delay):
    print("  Waiting for %s acquisitions before saving file" % acq_delay)
    acqstart = int(mi.query("ACQ:NUMACQ?"))
    acqnow = acqstart
    firstloop = 1
    while acqnow < (acqstart + acq_delay):
        if firstloop == 1:
            print("  Acqs gotten:", end = " ")
            firstloop = 0
        time.sleep(3)
        acqnow = int(mi.query("ACQ:NUMACQ?"))
        print("%d" % (acqnow - acqstart), end="...")
    print("Reached at least %d acqs!" % acq_delay)