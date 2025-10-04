
%% merge groundwater all years

clear; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\7_discharges\KPS\';

files=dir([inDir,'KPS_*20130101_20140101_wq.csv']);

for ff=1:length(files)
    outdata=[];
    infile=[inDir,files(ff).name];
    
    disp(infile);
    data=tfv_readBCfile_CS(infile);
    
    fields=fieldnames(data);
    
    for yy=1980:2024
        tdiff=datenum(2013,1,1)-datenum(yy,1,1);
        newDates=data.Date-tdiff;
        
        if yy==1980
            outdata.Date=newDates(1:end-1);
            
            for ss=2:length(fields)
                outdata.(fields{ss})=data.(fields{ss})(1:end-1);
            end
            
        else
            outdata.Date=[outdata.Date; newDates(1:end-1)];
            
            for ss=2:length(fields)
                outdata.(fields{ss})=[outdata.(fields{ss}); data.(fields{ss})(1:end-1)];
            end
            
        end
    
    end
    
    outfile=strrep(infile,'20130101_20140101','19800101_20241231');
    disp(outfile);
    fileID = fopen(outfile,'w');
    header='Date,Q,Salt,Temp,Ones,Zeros,DO';
    fprintf(fileID,'%s\n',header);
    for i=1:length(outdata.Date)
        fprintf(fileID,'%s',datestr(outdata.Date(i),'dd/mm/yyyy HH:MM:SS'));
        for ss=2:length(fields)
            fprintf(fileID,',%4.4f',outdata.(fields{ss})(i));
        end

        fprintf(fileID,'%s\n','');
    
    end
    fclose(fileID);
    
    
end
