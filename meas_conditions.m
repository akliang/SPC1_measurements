% Started on 2010-06-08
% The design of this database is to encourage many variations of measurements
% Users should feel free to modify and create multiple versions of conditions
% If you want to make a one-time matrix, you can always modify the RMATRIX
% locally in your code.

% The measurement script you are using will export the actual RMATRIX
% used in the measurement, including any modifications and add-ons.

switch meas.MeasCond

    case {'TwinFlood','TwinDark'}
        meas.BaseNameVars={'R1','R26','R27','R13','R14'};
        
        switch meas.RMATvers
            case 1
            multi.RMATheader={
            'R1'  'R26' 'R27' 'R11'  'R13'  'R14'};
            multi.RMATRIX=[
            1      20    10     0      1      1
            1      10    10     0      2      2
            1000   10    10     0      1      1
            1000   10    10     0      2      2
            ];
        
            case 2
            multi.RMATheader={
            'R1'  'R26' 'R27' 'R11'  'R13'  'R14'};
            multi.RMATRIX=[
            1      20    10     0      1      1
            1      10    10     0      2      2
           %1000   10    10     0      1      1
           %1000   10    10     0      2      2
            ];
        end

    case {'FloodLeakageNoise','DarkLeakageNoise'}
        env.G3ExtClock=100000; env.UseExtClock=1;
        meas.BaseNameVars={'R1','R26','R27'};
        
        switch meas.RMATvers
            case 1
            multi.RMATheader={
            'R1'  'R26' 'R27'  'R11' 'R13' 'R14'};
            multi.RMATRIX=[
            1      200   200    0     1     1
           %2      0     200    0     1     1     % not necessary for PSI-2
           %5      0     1000   0     1     1     % not necessary for PSI-2
           %10     0     50     0     1     1     % not necessary for PSI-2
            20     0     50     0     1     1
            50     0     50     0     1     1
            100    0     200    0     1     1
            200    0     30     0     1     1
            400    0     100    0     1     1
            1000   0     5      0     1     1
            2000   0     5      0     1     1
            4000   0     5      0     1     1
            6000   0     5      0     1     1
            8900   0     5      0     1     1
            11900  0     5      0     1     1
            15700  0     5      0     1     1
            19550  0     5      0     1     1 
           %40000  0     2      0     1     1     %added 2010-04-27, mk
           %60000  0     2      0     1     1     %added 2010-04-27, mk
            ];
        end


end




meas.MFileCond=[ mfilename() '.m' ];