
import visa


def run():

    siggenip = "192.168.66.84"

    # connect to the siggen and change waveform
    rm = visa.ResourceManager('@py')
    mi = rm.open_resource("TCPIP::" + siggenip + "::INSTR")

    # set correct setting values
    query = [
      ["save:waveform:fileformat spreadsheetcsv"],
    ]
    for q in query:
        mi.write(q[0])


# *IDN?
# *RCL 3 (restore instrument settings from mem location 3)
# *SAV 3 (save setting to mem location 3)
# *RST (set siggen to Default)
# SOURCE[12]:FUNCTION:SHAPE [sinusoid, square, pulse, ramp, user1]
# SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:HIGH 1V
# SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:LOW  1V
# SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:OFFSET  1V
# SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:AMPLITUDE  1V (not working)
# SOURCE[12]:VOLTAGE:UNIT [vpp, vrms, dbm]


