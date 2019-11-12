
import visa


def run():

    siggenip = "192.168.66.85"

    # connect to the siggen and change waveform
    rm = visa.ResourceManager('@py')
    mi = rm.open_resource("TCPIP::" + siggenip + "::INSTR")

    # set correct setting values
    query = [
      ["export:filename \"%s\"" % screenshotfile],
      ["save:waveform:fileformat spreadsheetcsv"],
    ]
    for q in query:
        mi.write(q[0])

    # write some oscilloscope settings to the envfh file
    query = ["*IDN?", "ch1?", "ch2?", "ch3?", "ch4?", "math1?", "math2?", "math3?", "math4?"]
    for q in query:
        envfh.write(q + ": ")
        envfh.write(mi.query(q))

    # export data
    # note: from this point forward, the path must be windir
    query = [
        ["export start"],
        ["save:waveform ch1,\"%s\\\\%s\"" % (windir, "ch1.csv")],
        ["save:waveform ch2,\"%s\\\\%s\"" % (windir, "ch2.csv")],
        ["save:waveform ch3,\"%s\\\\%s\"" % (windir, "ch3.csv")],
        ["save:waveform ch4,\"%s\\\\%s\"" % (windir, "ch4.csv")],
        ["save:waveform math1,\"%s\\\\%s\"" % (windir, "math1.csv")],
        ["save:waveform math2,\"%s\\\\%s\"" % (windir, "math2.csv")],
        ["save:waveform math3,\"%s\\\\%s\"" % (windir, "math3.csv")],
        ["save:waveform math4,\"%s\\\\%s\"" % (windir, "math4.csv")],
    ]
    for q in query:
        mi.write(q[0])