function [ userdata ] = g3_acquisition_userdata( setup, env )
%g3_acquisition_userdata prepare userdata array for g3_startacq

userdata=[
5 % header version
1000*env.V(1)
1000*env.V(2)
1000*env.V(3)
1000*env.V(4)
1000*env.V(5)
1000*env.V(6)
1000*env.V(7)
1000*env.V(8)
1000*env.V(9)
1000*env.V(10)
1000*env.V(11)
1000*env.V(12) 
1000*env.V(13) 
1000*env.V(14) 
1000*env.V(16) 
1000*env.V(17) 
env.G3ExtClock/(1000) % Tau1_Clock in kHz - to accomodate short
bin2dec(setup.PF_dataCardDIPs)   % can be used to derive nominal gain
bin2dec(setup.PF_dataBoardDIPs)  % can be used to derive nominal gain
bin2dec(setup.PF_arrayLogicDIPs) % on classic glue logic, used for PSI3 reset counter
];

userdata=round(userdata);

end

