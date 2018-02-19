  
import visa
import os
import subprocess
import re
from time import gmtime,strftime,time
import sys

def run(measdir,dfileprefix):
  "Connects to and downloads all probe and math channels from the oscilloscope, also saves oscilloscope settings"
  # note: dont forget to mountpsidata on the oscilloscope

  utime=int(time())
  utime -= 2  # grab the SMU data from a couple seconds before, to avoid writing race condition
  scopeip="192.168.66.85"

  if len(measdir)>100:
    print "Error: directory length (%s) is too long, scope can only accept 128 chars" % (measdir)
    print "Note: script limit set to 100 char to leave room for filenames"
    return

  # create a windows path equivalent of measdir
  windir=re.sub(r"/",r"\\\\",measdir)
  windir=re.sub(r"^\\\\mnt\\\\ArrayData",r"P:",windir)

  # paths to files created by this function
  screenshotfile="%s\\\\export_screenshot.png" % (windir)
  envfile="%s/environment.txt" % (measdir)
  envfh=open(envfile,'w')
 
  # add SMU information to env file
  smudata=subprocess.check_output("grep %d ../../measurements/spc/%s_.session | head -n 1" % (utime,dfileprefix),shell=True)
  envfh.write(smudata)
  
  
  # connect to the scope and start gathering data
  rm=visa.ResourceManager('@py')
  mi=rm.open_resource("TCPIP::" + scopeip + "::INSTR")
  
  # set correct setting values
  query=[
  ["export:filename \"%s\"" % (screenshotfile) ], 
  ["save:waveform spreadsheetcsv"],
  ]
  for q in query:
    mi.write(q[0])
  
  
  # write some oscilloscope settings to the envfh file
  query=[ "*IDN?" , "ch1?" , "ch2?" , "ch3?" , "ch4?" , "math1?" , "math2?" , "math3?" , "math4?" ]
  for q in query:
    envfh.write(q + ": ")
    envfh.write(mi.query(q))
 
 
  # export data
  # note: from this point forward, the path must be windir  
  query=[
  ["export start"], 
  ["save:waveform ch1,\"%s\\\\%s\"" % (windir,"ch1.csv")],
  ["save:waveform ch2,\"%s\\\\%s\"" % (windir,"ch2.csv")],
  ["save:waveform ch3,\"%s\\\\%s\"" % (windir,"ch3.csv")],
  ["save:waveform ch4,\"%s\\\\%s\"" % (windir,"ch4.csv")],
  ["save:waveform math1,\"%s\\\\%s\"" % (windir,"math1.csv")],
  ["save:waveform math2,\"%s\\\\%s\"" % (windir,"math2.csv")],
  ["save:waveform math3,\"%s\\\\%s\"" % (windir,"math3.csv")],
  ["save:waveform math4,\"%s\\\\%s\"" % (windir,"math4.csv")],
  ]
  for q in query:
    mi.write(q[0])


  # clean up the envfh file handle
  #envfh.flush()
  #os.fsync(envfh.fileno())
  envfh.close()

