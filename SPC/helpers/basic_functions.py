
import subprocess
import re

# if this is the only function in basic_functions, perhaps it can go back to the _general script
def get_smu_data(SPCsetup_path):

    smu_data = subprocess.check_output(
        "grep DFILEPREFIX %s | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'" % SPCsetup_path, shell=True)
    hostname = subprocess.check_output(
        "grep SMUHOST %s | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'" % SPCsetup_path, shell=True)
    smu_data = re.sub("\$\(hostname\)_", hostname.decode('utf-8'), smu_data.decode('utf-8'))
    smu_data = smu_data.rstrip()  # take off newline

    return smu_data
