wd=system('pwd')
set title sprintf("%s %s",wd,F)
set xlabel "Time (s)"
set ylabel "Volts"
#set y2label "Volts"
set y2label "Current (A)"
replot
set term push
set term png
set output "test.png"
replot
set output
set term pop
replot
