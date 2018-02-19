
# runs on python2.7 (untested for python3.2)
# package dependencies: pyvisa, pyvisa-py

import numpy as np
import os
from time import sleep,gmtime,time,strftime
import sys
import io
import subprocess
import re
sys.path.append('./helpers')
import download_oscope_data

print """
Checklist before starting:
- Is "./multim_2636A_unified.sh SPCsetup1" is running?
- Is "./multim_2636A_ctrlSPC_amp.sh SPCsetup1" is running?
- Did you set the Vcc and other default voltages?  (todo - make this automatic)
- Did you start the "!ext_bias_ctrl SPCpytrigger" function?
- Did you mount psidata on the oscilloscope?
"""

raw_input("Press ENTER to continue...")

# make the working directory
unixdir="/mnt/ArrayData/MasdaX/2018-01/measurements"
dtag=strftime("%Y%m%dT%H%M%S",gmtime())
utime=int(time())
workdir="%s/%s" % (unixdir,dtag)
os.mkdir(workdir)

# write the SPCsetup[12] information
dfileprefix=subprocess.check_output("grep DFILEPREFIX ../SPCsetup1 | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'",shell=True)
hostname=subprocess.check_output("hostname",shell=True)
hostname=hostname.rstrip()  # take off newline
dfileprefix=re.sub("\$\(hostname\)_",hostname,dfileprefix)
dfileprefix=dfileprefix.rstrip()  # take off newline
idfh = open("%s/id.txt" % (workdir),'w')
idfh.write(dfileprefix)
idfh.close()



# todo: copy the method used in download_oscope_data
pytrigger="/mnt/ArrayData/MasdaX/2018-01/scriptmeas/flags/2636_pytrigger.flag"
if os.path.isfile(pytrigger):
  os.remove(pytrigger)


dircnt=1  # variable used to create separate folders for each meas point
#for F in np.linspace(0,8,num=33,endpoint=True):
#  for G in np.linspace(0,8,num=17,endpoint=True):
for F in np.linspace(0,6,num=61,endpoint=True):
  for G in np.linspace(0,6,num=25,endpoint=True):

    # write the voltages to the SPCpytrigger file
    # for some reason, it MUST have two newlines in order for !ext_bias_ctrl to work
    vstring="v3(%0.2f)\n\nv5(%0.2f)\n\n" % (F,G)
    print "Sending voltages to SMU: %s" % (re.sub("\n"," ",vstring))
    fh = open(pytrigger,'wb')
    fh.write(unicode(vstring))
    fh.close()

    # wait for the SMU to consume the file
    cnt=1
    cnt_thresh=10
    sys.stdout.write("Waiting for SMU to consume voltages file...")
    sys.stdout.flush()
    while os.path.isfile(pytrigger):
      if (cnt%5 == 0):
        sys.stdout.write(".....")
        sys.stdout.flush()
        if (cnt > cnt_thresh):
          print "no response after %d seconds, is it stuck?" % (cnt)
      sleep(1)
      cnt += 1

    # perform actions after SMU consumes the file
    print "\n  Voltage file gone... assuming SMU consumed it"
    sleepwait=40
    print "  Waiting %d seconds for oscilloscope to settle in" % (sleepwait)
    sleep(sleepwait)
    print "  Downloading oscilloscope data"
    # make the directory to store the oscilloscope data
    measdir="%s/meas%03d" % (workdir,dircnt)
    os.mkdir(measdir)
    download_oscope_data.run(measdir,dfileprefix)
    dircnt += 1


print "Voltage loop finished, terminating !ext_bias_ctrl with FIN"
vstring="FIN"
fh = open(pytrigger,'w')
fh.write(vstring)
fh.close()

