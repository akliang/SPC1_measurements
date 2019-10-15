
import visa
import sys
from time import sleep,gmtime,time,strftime
import re
import os


scopeip="192.168.66.85"
dtag=strftime("%Y%m%dT%H%M%S",gmtime())

# make the data folder
if len(sys.argv)==1:
  # set a default filename
  datafolder="%s_oscope_data" % (dtag)
else:
  datafolder=sys.argv[1]
  # if the special dtag keyword is there, then insert the dtag
  datafolder=re.sub("dtag",dtag,datafolder)
# make the folder (local, unix file path)
os.makedirs(datafolder)
# append the current directory (in win format)
datafolder="P:\\MasdaX\\2018-01\\scriptmeas\\SPC\\%s" % (datafolder)
print("datafolder is %s" % datafolder)


# connect to the scope and start gathering data
rm=visa.ResourceManager('@py')
mi=rm.open_resource("TCPIP::" + scopeip + "::INSTR")
# set correct setting values
query=[
["save:waveform spreadsheetcsv"],
["save:waveform ch1,\"%s\\\\%s\"" % (datafolder,"ch1.csv")],
["save:waveform ch2,\"%s\\\\%s\"" % (datafolder,"ch2.csv")],
["save:waveform ch3,\"%s\\\\%s\"" % (datafolder,"ch3.csv")],
["save:waveform ch4,\"%s\\\\%s\"" % (datafolder,"ch4.csv")],
["save:waveform math1,\"%s\\\\%s\"" % (datafolder,"math1.csv")],
["save:waveform math2,\"%s\\\\%s\"" % (datafolder,"math2.csv")],
["save:waveform math3,\"%s\\\\%s\"" % (datafolder,"math3.csv")],
["save:waveform math4,\"%s\\\\%s\"" % (datafolder,"math4.csv")]
]
for q in query:
  mi.write(q[0])



