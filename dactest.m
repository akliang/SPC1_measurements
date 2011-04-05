function DAC= dactest(Vtoset,Dpot)
%dactest(Vtoset,ADCcard,analogcard)
DACDIR='../../DACchar_results/';
% temporarily hard-coded to d1
%searchmat=dir([DACDIR '*'  '_' ADCcard '_' analogcard '.mat']) 
searchmat=dir([DACDIR '*'  '_' Dpot  '.mat']); 
searchmat=struct2cell(searchmat);
numofmatches=size(searchmat,2);
matfile=[DACDIR searchmat{1,1}];
if(numofmatches>1)
    for k1=1:numofmatches
        dates(k1)=str2num(searchmat{1,k1}([1:8 10:15]));
    end
    [C I]=max(dates);
     matfile=[DACDIR searchmat{1,I}];
elseif(numofmatches<1)
     error('This analog card has not yet been characterized');
end

load(matfile);

for k=1:10
	DAC(k)=round((Vtoset(k)-Dpot{k}.offset)/Dpot{k}.VperDAC);
end

% temporary fix since matfile isn't large enough
%DAC(9)=510;
%DAC(10)=510;

end