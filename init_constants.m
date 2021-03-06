% file channel numbers
ts=3; %time-step column
v1=4;
v2=v1+2;
v3=v2+2;
v4=v3+2;
v5=v4+2;
v6=v5+2;
i1=v1+1;
i2=v2+1;
i3=v3+1;
i4=v4+1;
i5=v5+1;
i6=v6+1;

% channel-to-column mapping
chan2vcol=[ v1 v2 v3 v4 v5 v6 ];
chan2icol=[ i1 i2 i3 i4 i5 i6 ];

% Array transistor dimensions
L.GL_Array=	[32	15	14	13	12	11	10	9	8	7	6	5	4	3	2	1];
L.GL_PCB=	[1	16	15	14	13	12	11	10	9	8	7	6	5	4	3	2]; 

L.SF_W=		[90	90	90	60	90	90	60	30	90	90	90	60	90	90	60	30];
L.SF_L=		[10	10	5	5	5	5	5	10	10	10	5	5	5	5	5	10];

L.ADDR_W=	[90	90	60	20	90	90	60	30	90	90	60	20	90	90	60	30];
L.ADDR_L=	[10	5	10	10	10	5	10	10	10	5	10	10	10	5	10	10];

ll=@(gl) find(L.GL_PCB==gl);

