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

#F='./test04_TAA-29B1-1_ch1=Vsfbgnd_ch2=DL06_ch3=Vgnd_ch4=Vcc_ch5=GL04_ch6=HI_simwork_.session'

plot F u 3:v1 w p lc 1, F u 3:i1 w p lc 1 axis x1y2, F u 3:v2 w p lc 2, F u 3:i2 w p lc 2 axis x1y2, F u 3:v3 w p lc 3, F u 3:i3 w p lc 3 axis x1y2, F u 3:v4 w p lc 4, F u 3:i4 w p lc 4 axis x1y2, F u 3:v5 w p lc 5, F u 3:i5 w p lc 5 axis x1y2, F u 3:v6 w p lc 6, F u 3:i6 w p lc 6 axis x1y2

#load "./replot_loop.gnuplot"

plot \
	F u ts:v1 w p lc 1, \
	F u ts:i1 w l lc 1 axis x1y2, \
	F u ts:v2 w p lc 2, \
	F u ts:i2 w l lc 2 axis x1y2, \
	F u ts:v3 w p lc 3, \
	F u ts:i3 w l lc 3 axis x1y2, \
	F u ts:v4 w p lc 4, \
	F u ts:i4 w l lc 4 axis x1y2, \
	F u ts:v5 w p lc 5, \
	F u ts:i5 w l lc 5 axis x1y2, \
	F u ts:v6 w p lc 6, \
	F u ts:i6 w l lc 6 axis x1y2 

plot \
	F u ts:v1 w p lc 1, \
	F u ts:v2 w p lc 2, \
	F u ts:i2 w l lc 2 axis x1y2, \
	F u ts:v3 w p lc 3, \
	F u ts:v4 w p lc 4, \
	F u ts:v5 w p lc 5, \
	F u ts:v6 w p lc 6

