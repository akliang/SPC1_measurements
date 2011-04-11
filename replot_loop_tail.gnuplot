pause 0.5
te=system(sprintf("tail -n 1 %s | gawk '{ print $3 }'", F))
set xrange [te-tspan:te]
replot
reread
