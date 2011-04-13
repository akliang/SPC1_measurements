pause 0.5
to=system(sprintf("head -n 1 %s | gawk '{ print $3 }'", F))
te=system(sprintf("tail -n 1 %s | gawk '{ print $3 }'", F))
set xrange [te-tspan-to:te-to]
replot
reread
