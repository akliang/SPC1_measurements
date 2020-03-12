
import time


def acq_delayer(mi, acq_delay):
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


def set_recordlength(mi, val):
    print("  Setting record length to %d" % val)
    curr_recordlength = float(mi.query("HORIZONTAL:MODE:RECORDLENGTH?"))
    if curr_recordlength != val:
        samplerate_gainfac = val / curr_recordlength
        new_samplerate = float(mi.query("HORIZONTAL:MODE:SAMPLERATE?")) * samplerate_gainfac
        mi.write("HORIZONTAL:MODE:SAMPLERATE %f" % new_samplerate)


