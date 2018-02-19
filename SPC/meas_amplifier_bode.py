
# runs on python2.7 (untested for python3.2)
# package dependencies: pyvisa, pyvisa-py

from __future__ import division
import numpy as np
import os
from time import sleep,gmtime,time,strftime
import sys
import io
import subprocess
import re
import visa
sys.path.append('./helpers')
import download_oscope_data

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


# set the circuit to a specific operating point
vstring="v1(8)\n\nv2(0)\n\nv3(2.5)\n\nv4(1.5)\n\nv5(2.5)\n\n"
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
print "\n  Voltage file gone... assuming SMU consumed it"



# define the frequency range to sweep
logpoints=[1 , 1.25 , 1.5 , 1.75]
logvals=[10**x/10 for x in logpoints]
decades=[100 , 1000 , 10000 , 100000]
#decades=[100]
freqs=[]
for f in decades:
  tmp=[f*x for x in logvals]
  freqs += tmp

# input pulse size (in volts)
inpulse=0.100


# connect to the siggen
SIGGEN_IP="192.168.66.84"
rm=visa.ResourceManager('@py')
mi=rm.open_resource("TCPIP::" + SIGGEN_IP + "::INSTR")
mi.write("SOURCE1:VOLT %f" % (inpulse))
mi.write("OUTPUT1 ON")


# connect to the oscilloscope
OSCOPE_IP="192.168.66.85"
mi2=rm.open_resource("TCPIP::" + OSCOPE_IP + "::INSTR")


dircnt=1  # variable used to create separate folders for each meas point
for F in freqs:

  # sweep through the frequencies
  mi.write("SOURCE1:FREQ %f" % (F))
  # calculate the width to set the scope to (10 divs in horiz direction)
  # num horizon divs changeable with HORizontal:DIVisions command
  print type(F)
  fperiod=1/F
  numwaves=3
  tot_time=fperiod*numwaves
  time_per_div=tot_time/10
  print "  Frequency is %f, numwaves %f, time_per_div %0.4e" % (F,numwaves,time_per_div)
  mi2.write("HOR:MODE:SCALE %f" % (time_per_div))
  sleepwait=40
  print "  Waiting %d seconds for oscilloscope to settle in" % (sleepwait)
  sleep(sleepwait)

  print "  Downloading oscilloscope data"
  # make the directory to store the oscilloscope data
  measdir="%s/meas%03d" % (workdir,dircnt)
  os.mkdir(measdir)
  download_oscope_data.run(measdir,dfileprefix)
  dircnt += 1

print "done!"

