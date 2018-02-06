
import visa
import os
import subprocess
import re
from time import gmtime,strftime,time

# note: dont forget to mountpsidata on the oscilloscope

dir="/mnt/ArrayData/MasdaX/2018-01/measurements"
windir="P:\\MasdaX\\2018-01\\measurements"
scopeip="192.168.66.85"
dtag=strftime("%Y%m%dT%H%M%S",gmtime())
utime=int(time())

dfileprefix=subprocess.check_output("grep DFILEPREFIX ../SPCsetup1 | grep -v '#' | tail -n 1 | sed -e 's/.*=//' -e 's/\"//g'",shell=True)
hostname=subprocess.check_output("hostname",shell=True)
hostname=hostname.rstrip()  # take off newline
dfileprefix=re.sub("\$\(hostname\)_",hostname,dfileprefix)
dfileprefix=dfileprefix.rstrip()  # take off newline
unixdfileprefix="%s/%s_%s_%s" % (dir,dtag,utime,dfileprefix)
windfileprefix="%s\\%s_%s_%s" % (windir,dtag,utime,dfileprefix)



screenshotfile="%s_screenshot.png" % (windfileprefix)
envfile="%s_scopeenv.txt" % (unixdfileprefix)
envfh=open(envfile,'w')



rm=visa.ResourceManager('@py')
mi=rm.open_resource("TCPIP::" + scopeip + "::INSTR")

# set correct setting values
query=[
["export:filename \"%s\"" % (screenshotfile) ], 
["save:waveform spreadsheetcsv"],
]
for q in query:
  print q[0]
  mi.write(q[0])


# write some oscilloscope settings to the envfh file
query=[ "*IDN?" , "ch1?" , "ch2?" , "ch3?" , "ch4?" , "math1?" , "math2?" , "math3?" , "math4?" ]
for q in query:
  print q
  envfh.write(q + ": ")
  envfh.write(mi.query(q))
envfh.flush()
os.fsync(envfh.fileno())
envfh.close()

# export data
query=[
["export start"], 
["save:waveform ch1,\"%s_%s\"" % (windfileprefix,"ch1.csv")],
["save:waveform ch2,\"%s_%s\"" % (windfileprefix,"ch2.csv")],
["save:waveform ch3,\"%s_%s\"" % (windfileprefix,"ch3.csv")],
["save:waveform ch4,\"%s_%s\"" % (windfileprefix,"ch4.csv")],
["save:waveform math1,\"%s_%s\"" % (windfileprefix,"math1.csv")],
["save:waveform math2,\"%s_%s\"" % (windfileprefix,"math2.csv")],
["save:waveform math3,\"%s_%s\"" % (windfileprefix,"math3.csv")],
["save:waveform math4,\"%s_%s\"" % (windfileprefix,"math4.csv")],
]
for q in query:
  print q[0]
  mi.write(q[0])



