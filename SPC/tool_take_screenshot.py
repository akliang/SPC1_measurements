
import visa
import sys
from time import sleep,gmtime,time,strftime
import re


scopeip="192.168.66.85"
dtag=strftime("%Y%m%dT%H%M%S",gmtime())

if len(sys.argv)==1:
  # set a default filename
  screenshotfile="%s_oscope_screenshot.png" % (dtag)
else:
  screenshotfile=sys.argv[1]
  # if the special dtag keyword is there, then insert the dtag
  screenshotfile=re.sub("dtag",dtag,screenshotfile)
  # add the png file extension, if necessary
  if ".png" not in screenshotfile:
    screenshotfile="%s.png" % (screenshotfile)
# append the current directory (in win format)
screenshotfile="P:\\MasdaX\\2018-01\\scriptmeas\\SPC\\%s" % (screenshotfile)

print("screenshotfile is %s" % screenshotfile)


# connect to the scope and start gathering data
rm=visa.ResourceManager('@py')
mi=rm.open_resource("TCPIP::" + scopeip + "::INSTR")
# set correct setting values
query=[
["export:filename \"%s\"" % (screenshotfile) ],
["export start"]
]
for q in query:
  mi.write(q[0])



