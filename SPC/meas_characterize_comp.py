
from helpers import download_oscope_data as dod


def run(mi, measdir, smu_data):

    print(measdir)
    print(smu_data)

    # record the current data on the oscilloscope
    #dod.run(mi, measdir, smu_data)

    dircnt = 1  # variable used to create separate folders for each meas point
    measdir2 = "%s/meas%04d" % (measdir, dircnt)
    dod.run(mi, measdir2, smu_data)

    dircnt += 1






