clear; close all;

% filename='MHMAN02_03_2013.txt';
% fid = fopen(filename,'rt');
% 
% data = [];
% 
% EOF = 0;
% inc = 1;
% while ~EOF
%     
%     sLine = fgetl(fid);
%     
%     if sLine == -1
%         EOF = 1;
%     else
%         dataline = regexp(sLine,',','split');
%         
%         data.H(inc)= str2double(dataline{1});
%         strtmp=dataline{2};
%         
%         dataline2 = regexp(strtmp,'/','split');
%         strtmp2=dataline2{1};
%         data.Time(inc)= datenum(strtmp2,'yyyymmdd.HHMM');
%         
%         inc = inc + 1;
%     end
% end
% 
% data2.H=data.H(1:12:end)*0.01;
% data2.Time=data.Time(1:12:end);
% 
% for i=2:length(data2.H)
%     if data2.H(i)<-10
%         data2.H(i)=data2.H(i-1);
%     end
% end
% 
% data.H=data.H*0.01;
% 
% for i=2:length(data.H)
%     if data.H(i)<-10
%         data.H(i)=data.H(i-1);
%     end
% end
% 
% data.H=data.H-0.6350;

inDir='Z:\Busch\Studysites\Peel\2018_Modelling\Peel_1998_model_sensitivity\standard\BC\Flow\';

files=dir([inDir,'*.csv']);

for ff=1 %:length(files)
    infile=[inDir,files(ff).name];
    disp(infile);
    fdata=tfv_readBCfile(infile);
    
    if ff==1
        tflow=fdata.Flow;
    else
        tflow=tflow+fdata.Flow;
    end
end


%%
load peel.mat;

Sal=peel.ph7.SAL;

Sdate=floor(Sal.Date);
uDate=unique(Sdate);

for uu=1:length(uDate)
    sss=find(Sdate==uDate(uu));
    
    tmpS=Sal.Data(sss);
    tmpD=Sal.Depth(sss);
    
    tmpI=find(tmpD==min(tmpD));
    Sdata(uu)=tmpS(tmpI(1));
end

%Sdata(174:176)=Sdata(174:176)+11;
%%

infile='.\NAR_Inflow_2013.csv';

Ndata=tfv_readBCfile(infile);
Nfield=fieldnames(Ndata);

%newH=interp1(data.Time,data.H,Ndata.Date);
newF=interp1(fdata.Date,tflow,Ndata.Date);
newSal=interp1(uDate,Sdata,Ndata.Date);

header='ISOTime,Flow,Sal,Temp,ones,zeroes,TSS,Oxy,Sil,Amm,Nit,FRP,DOC_T,POC_T,DON_T,PON_T,OP,CHLA,TN,TP';

fileID = fopen('Mandura_Inflow_2013_Flow.csv','w');
fprintf(fileID,'%s\n',header);

for j=1:length(Ndata.Date)
    fprintf(fileID,'%s',datestr(Ndata.Date(j),'dd/mm/yyyy HH:MM:SS'));
    fprintf(fileID,',%6.4f',newF(j));
    fprintf(fileID,',%6.4f',newSal(j));
    for f=4:length(Nfield)
        fprintf(fileID,',%6.4f',Ndata.(Nfield{f})(j));
    end
fprintf(fileID,'%s\n','');

end
fclose(fileID);