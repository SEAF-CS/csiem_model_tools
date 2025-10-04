
clear; close all;

datearray=datenum(2022,1,1):1/24:datenum(2023,1,1);

t1=datenum(2022,3,1);
t2=datenum(2022,4,1);

ls=[115.7169 -32.1425];  %[115.7085 -32.1537];  
le=[115.6965 -32.0591];  %[115.6966 -32.0486];

outfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\9_operations\dredging\mimic_dredge_202203_v2.csv';

header='Date,lon,lat,Salt,Temp,TSS,DO,AMM,NIT,FRP,FRPADS,POC,DOC,PON,DON,POP,DOP,GRN,BGA,CRYPT,MDIAT,DINO,ZEROS,ONES';
fileID = fopen(outfile,'w');
fprintf(fileID,'%s\n',header);

for i=1:length(datearray)
    if mod(i,1000)==0
        disp(datestr(t0,'dd/mm/yyyy HH:MM:SS'));
    end
    t0=datearray(i);
    datev=datevec(t0);
    datevh=datev(4);

    if t0<=t1
        lon=ls(1);
        lat=ls(2);
    elseif t0>=t2
        lon=le(1);
        lat=le(2);
    else
        lon=ls(1)+(le(1)-ls(1))/(t2-t1)*(t0-t1);
        lat=ls(2)+(le(2)-ls(2))/(t2-t1)*(t0-t1);
    end

    fprintf(fileID,'%s,',datestr(t0,'dd/mm/yyyy HH:MM:SS'));
    fprintf(fileID,'%4.4f,',lon);
    fprintf(fileID,'%4.4f,',lat);

    if (t0>t1 && t0<t2 && datevh>=8 && datevh<16)
        fprintf(fileID,'%s\n','0,0,1000,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1');
    else
        fprintf(fileID,'%s\n','0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1');
    end

end

fclose(fileID);