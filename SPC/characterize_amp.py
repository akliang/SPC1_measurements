
import numpy as np
import os
from time import sleep

print """
Checklist before starting:
- Is "./multim_2636A_unified.sh SPCsetup1" is running?
- Is "./multim_2636A_ctrlSPC_amp.sh SPCsetup1" is running?
- Did you start the "!ext_bias_ctrl SPCpytrigger" function?
- Did you mount psidata on the oscilloscope?
"""

raw_input("Press ENTER to continue...")

pytrigger="/mnt/ArrayData/MasdaX/2018-01/scriptmeas/flags/2636_pytrigger.flag"
if os.path.isfile(pytrigger):
  os.remove(pytrigger)




for F in np.linspace(0,8,num=33,endpoint=True):
  for G in np.linspace(0,8,num=17,endpoint=True):
      fh = open(pytrigger,'w')
      fh.write("v3(%0.2f)\nv5(%0.2f)\n" % (F,G))
      fh.close()

      while os.path.isfile(pytrigger):
        sleep(1)

