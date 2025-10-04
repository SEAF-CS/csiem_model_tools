
%% merge groundwater all years

clear; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\8_intakes\Verve\';

files=dir([inDir,'PRP_*20130101_20140101_wq.csv']);

for ff=1:length(files)
    outdata=[];
    infile=[inDir,files(ff).name];
    
    disp(infile);
    data=tfv_readBCfile_CS(infile);
    
    fields=fieldnames(data);
    
    for yy=2010:2022
        tdiff=datenum(2013,1,1)-datenum(yy,1,1);
        newDates=data.Date-tdiff;
        
        if yy==2010
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
    
    outfile=strrep(infile,'20130101_20140101','20100101_20221331');
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
