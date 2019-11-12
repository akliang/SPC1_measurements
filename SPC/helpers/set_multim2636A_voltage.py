
import os
import subprocess
import tempfile

def send_scpi(vstring):
    # this function attempts to mimic the multim_ctrl send_cmd() function
    # it directly writes the voltage to the /dev/shm SCPI file, just like send_cmd()
    # with this function, you don't need to run !ext_bias_ctrl anymore
    # but, you will need a direct connection (ssh or scp) to the /dev/shm of the machine running the SMUs
    # this function depends on a bash script called send_smu_cmd.sh
    # and a proxy port on eve (ssh -D 9998 eve)

    # make a temporarily file
    fd, temp_path = tempfile.mkstemp()

    # Write vtrigger to a pre-file then move to pytrigger
    print('Writing "%s" to temp file %s' % (vstring, temp_path))
    fh = open(temp_path, 'wb')
    fh.write(vstring.encode())
    fh.close()

    # call the bash script to send the temp_file
    p1 = subprocess.Popen(['./helpers/send_smu_cmd.sh ../SPCsetup1 %s' % temp_path], shell=True)
    p1.wait()
    print("Ret code: %s" % p1.returncode)

    # clean up the temp file
    os.close(fd)
    os.remove(temp_path)
