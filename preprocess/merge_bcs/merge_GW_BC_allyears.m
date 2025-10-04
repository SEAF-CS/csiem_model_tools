
%% merge groundwater all years

clear; close all;

inDir='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\bc_repo\6_gw\CSV\';

files=dir([inDir,'*20131231.csv']);

for ff=1:length(files)
    outdata=[];
    infile=[inDir,files(ff).name];
    
    disp(infile);
    data=tfv_readBCfile(infile);
    
    fields=fieldnames(data);
    
    for yy=1980:2024
       % tdiff=datenum(2013,1,1)-datenum(yy,1,1);
        newDates=datenum(yy,1:12,1)'; %data.Date-tdiff;
        
        if yy==1980
            outdata.Date=newDates;
            
            for ss=2:length(fields)
                outdata.(fields{ss})=data.(fields{ss});
            end
            
        else
            outdata.Date=[outdata.Date; newDates];
            
            for ss=2:length(fields)
                outdata.(fields{ss})=[outdata.(fields{ss}); data.(fields{ss})];
            end
            
        end
    
    end
    
    outfile=strrep(infile,'20130101_20131231','19800101_20241201');
    disp(outfile);
    fileID = fopen(outfile,'w');
    header='Date,Flow,SAL,TEMP,Trace_1,WQ_NCS_SS1,WQ_OXY_OXY,WQ_NIT_AMM,WQ_NIT_NIT,WQ_PHS_FRP,WQ_PHS_FRP_ADS,WQ_OGM_DOC,WQ_OGM_POC,WQ_OGM_DON,WQ_OGM_PON,WQ_OGM_DOP,WQ_OGM_POP,WQ_PHY_GRN,WQ_PHY_BGA,WQ_PHY_CRYPT,WQ_PHY_MDIAT,WQ_PHY_DINO,WQ_TRC_TR1,WQ_TRC_TR2,WQ_TRC_TR3,WQ_TRC_TR4,WQ_TRC_AGE';
    fprintf(fileID,'%s\n',header);
    for i=1:length(outdata.Date)
        fprintf(fileID,'%s',datestr(outdata.Date(i),'dd/mm/yyyy'));
        for ss=2:length(fields)
            fprintf(fileID,',%4.4f',outdata.(fields{ss})(i));
        end

        fprintf(fileID,'%s\n','');
    
    end
    fclose(fileID);
    
    
end
