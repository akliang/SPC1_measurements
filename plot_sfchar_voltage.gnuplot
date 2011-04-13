ts=3
v1=4
v2=v1+2
v3=v2+2
v4=v3+2
v5=v4+2
v6=v5+2
i1=v1+1
i2=v2+1
i3=v3+1
i4=v4+1
i5=v5+1
i6=v6+1

set y2tics
set ytics nomirror

# For TFTrst tests with Vreset on ch3 and reading in voltage with bias current on ch2
plot \
	F u ($3-to):v1 w p lc 1, \
	F u ($3-to):v2 w l lc 2 axis x1y2, \
	F u ($3-to):v3 w l lc 3 axis x1y2, \
	F u ($3-to):v4 w p lc 4, \
	F u ($3-to):v5 w p lc 5, \
	F u ($3-to):v6 w p lc 6

