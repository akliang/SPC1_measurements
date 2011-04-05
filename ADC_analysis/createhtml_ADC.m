function createhtml_ADC(num,adccards,timest,filepath,bat,sa,uVperADCmatrix,errorADCmat)
foldpath=[filepath '/ADCchar.html'];
fid1=fopen(foldpath,'wt');
fprintf(fid1, '<html>\n \t<head>\n');
fprintf(fid1, '\t\t<title>ADC characterization</title>\n');
fprintf(fid1,'\t\t <h1><center>ADC Characterization</center></h1>\n');
fprintf(fid1,['\t\t <h2><center>ADC cards used : ' adccards '</center></h2>\n']);
fprintf(fid1,['\t\t <h2><center>Time Stamp : ' timest '</center></h2>\n']);
fprintf(fid1, '\t</head>\n\t<body>\n');


if(bat==true)
    fprintf(fid1,'\t\t\t\t\t<h3>Error ADC matrix</h3>\n');
    fprintf(fid1, '\t\t\t\t\t<table id="ErrorADCmatrix border=1 height=50%% width=50%%>\n');
    fprintf(fid1,'\t\t\t<tr>\n');
    fprintf(fid1,'\t\t\t\t<td><center>Ch no.</center> </td>\n');
    fprintf(fid1,'\t\t\t\t<td><center>ADC std.</center> </td>\n');
    fprintf(fid1,'\t\t\t\t<td><center>ADC mean</center> </td>\n');
    fprintf(fid1,'\t\t\t</tr>\n');
    fprintf(fid1,['\t\t\t<tr>\n' repmat('\t\t\t\t<td><center>%g</center></td>\n',1,sa{2}(2)) '\t\t\t</tr>\n'],errorADCmat.');;
    fprintf(fid1, '\t\t\t\t\t</table>\n');

else

    fprintf(fid1,'\t\t\t<li><a href="#uVperADCchart">uV/ADC chart</a></li>\n');
    fprintf(fid1, '\t\t<table border=1 height=50%% width=100%%>\n');


    for ind=1:2:num
        fprintf(fid1,'\t\t\t<tr>\n');
        fprintf(fid1,['\t\t\t\t<td width=50%% height=50%%><img src= " ./' ['fig' num2str(ind) '_' adccards '.png"']  'width=100%% height=100%% /> </td>\n']);
        fprintf(fid1,['\t\t\t\t<td width=50%% height=50%%><img src= " ./' ['fig' num2str(ind+1) '_' adccards '.png"'] 'width=100%% height=100%% /> </td>\n']);
        fprintf(fid1,'\t\t\t</tr>\n');
    end

    fprintf(fid1,'\t\t\t<tr>\n');

    fprintf(fid1,'\t\t\t\t<td colspan=1><center>\n');
    fprintf(fid1,'\t\t\t\t\t<h3><center>uV/ADC chart</center></h3>\n');
    fprintf(fid1, '\t\t\t\t\t<table id="uVperADCchart" border=1 height=50%% width=50%%>\n');
        fprintf(fid1,'\t\t\t<tr>\n');
        fprintf(fid1,'\t\t\t\t<td><center>Ch no./Vref</center></td>\n');
        fprintf(fid1,repmat('\t\t\t\t<td><center>%gV</center></td>\n',1,sa{1}(2)-1),uVperADCmatrix(1,2:end-1).');
        fprintf(fid1,'\t\t\t</tr>\n');
        fprintf(fid1,['\t\t\t<tr>\n' repmat('\t\t\t\t<td><center>%g</center></td>',1,sa{1}(2)) '\t\t\t</tr>\n'],uVperADCmatrix(2:end-1,:).');
        fprintf(fid1,'\t\t\t<tr>\n\t\t\t<td>\n \t\t\t</td>\n');
        fprintf(fid1,[repmat('\t\t\t\t<td><center>%g</center></td>',1,sa{1}(2))],uVperADCmatrix(end,2:end-1).');
        fprintf(fid1,'\t\t\t</tr>\n');
    fprintf(fid1, '\t\t\t\t\t</table>\n');
    fprintf(fid1,'\t\t\t\t</center></td>\n');

    fprintf(fid1,'\t\t\t</tr>\n');
fprintf(fid1, '\t\t</table>\n');
end

fprintf(fid1, '\t</body>\n</html>\n');
fclose(fid1);
end


