
from helpers import download_oscope_data2 as dod


def run(mi, measdir, smu_data):

    print(measdir)
    print(smu_data)

    # record the current data on the oscilloscope
    dod.run(mi, measdir, smu_data)





