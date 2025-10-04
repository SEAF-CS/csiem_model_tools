
%% merge groundwater all years

clear; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\7_discharges\NOD\';

files=dir([inDir,'*20230101_wq.csv']);
d2i=datenum(1980,1,1):datenum(2024,12,31);

for ff=2:length(files)
    outdata=[];
    infile=[inDir,files(ff).name];
    
    disp(infile);
    data=tfv_readBCfile_NOD(infile);
    
    fields=fieldnames(data);

    outdata.Date=d2i;

    for ss=2:length(fields)
        tmpdata=interp1(data.Date,data.(fields{ss}),d2i,'linear',mean(data.(fields{ss})));
        outdata.(fields{ss})=tmpdata;
    end
    
    outfile=strrep(infile,'20100101_20230101','19800101_20241231');
   % outfile='./test.csv';
    disp(outfile);
    fileID = fopen(outfile,'w');
    header='Date,Q,Salt,Temp,TSS,DO,AMM,NIT,FRP,FRPADS,POC,DOC,PON,DON,POP,DOP,GRN,BGA,CRYPT,MDIAT,DINO,ZEROS,ONES';
    fprintf(fileID,'%s\n',header);
    for i=1:length(outdata.Date)
        if mod(i,1000)==0
            disp(datestr(outdata.Date(i)));
        end
        fprintf(fileID,'%s',datestr(outdata.Date(i),'dd/mm/yyyy HH:MM:SS'));
        for ss=2:length(fields)
            fprintf(fileID,',%4.4f',outdata.(fields{ss})(i));
        end

        fprintf(fileID,'%s\n','');
    
    end
    fclose(fileID);
    
    
end
