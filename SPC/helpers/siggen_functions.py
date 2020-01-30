
import visa


def send_query(query):
    # send commands to the siggen
    # query syntax:
    # query = [
    #       ["save:waveform:fileformat spreadsheetcsv"],
    # ]
    # possible commands:
    # *IDN?
    # *RCL 3 (restore instrument settings from mem location 3)
    # *SAV 3 (save setting to mem location 3)
    # *RST (set siggen to Default)
    # OUTPUT[12]:STATE ON
    # SOURCE[12]:FUNCTION:SHAPE [sinusoid, square, pulse, ramp, user1]
    # SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:HIGH 1V
    # SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:LOW  1V
    # SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:OFFSET  1V
    # SOURCE[12]:VOLTAGE:LEVEL:IMMEDIATE:AMPLITUDE  1V (not working)
    # SOURCE[12]:VOLTAGE:UNIT [vpp, vrms, dbm]

    siggenip = "192.168.66.84"

    # connect to the siggen
    rm = visa.ResourceManager('@py')
    mi = rm.open_resource("TCPIP::" + siggenip + "::INSTR")

    # send command(s)
    # TODO: query first then execute
    # query = [
    #     [0, "OUTPUT1:STATE OFF"],
    #     [0, "OUTPUT2:STATE OFF"],
    #     [1, "SOURCE1:VOLTAGE:UNIT VPP"],
    #     [1, "SOURCE1:FUNCTION:SHAPE RAMP"],
    #     [1, "SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:HIGH %fV" % vhi],
    #     [1, "SOURCE1:VOLTAGE:LEVEL:IMMEDIATE:LOW  %fV" % vlo],
    #     [0, "OUTPUT1:STATE ON"],
    # ]
    #
    # for q in query:
    #     if q[0] == 0:
    #         print("immediately executing: %s" % q[1])
    #     elif q[0] == 1:
    #         t = q[1].split()
    #         t = "%s?" % t[0]
    #         print("querying first with: %s" % t)
    for q in query:
        if q[0].endswith("?"):
            print(mi.query(q[0]))
            print(q[0])
        else:
            mi.write(q[0])
            print(q[0])

    mi.close()





