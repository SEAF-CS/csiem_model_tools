
%% merge groundwater all years

clear; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\1_ocean\WQ\';

files=dir([inDir,'ocean_bgc_IMOS_20220101_20221231.csv']);

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
    
    outfile=strrep(infile,'20220101_20221231','20100101_20221331');
    disp(outfile);
    fileID = fopen(outfile,'w');
    header='Date,       TSS,       DO,       AMM,       NIT,       FRP,       POC,       DOC,       PON,       DON,       POP,       DOP,       GRN,       BGA,       CRYPT,       MDIAT,       DINO,       ZEROS,       ONES ';
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
