clear; close all;

loadnames={'WQ_DIAG_NCS_D_TAUB','SAL','TEMP','WQ_DIAG_TOT_LIGHT','WQ_DIAG_TOT_PAR','V_x','V_y','WQ_DIAG_TOT_EXTC','WVHT','WVDIR','WVPER','TAUC','TAUW','TAUCW'};
short_names={'TAUB','SAL','TEMP','LIGHT','PAR','Vx','Vy','EXTC','WVHT','WVDIR','WVPER','TAUC','TAUW','TAUCW'};
long_names={'bottom stress', 'salinity','temperature',...
    'light','Photosynthetically active radiation','Vx','Vy','EXTC','WVHT','WVDIR','WVPER','TAUC','TAUW','TAUCW'};
units ={'N/m2','PSU','degrees','W/m2','W/m2','m/s','m/s','/m','m','degree','s','N/m2','N/m2','N/m2'};

sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

%%

outDir='.\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

infile=[outDir,'extracted_2023_combined.mat'];
load(infile);

depth=load('extracted_2023_D.mat');

datediff=datenum(1958,11,17)-datenum(1858,11,17);
orb2022=load('orbital_2022.mat');orb2022.output.time=orb2022.output.time-datediff;
orb2023=load('orbital_2023.mat');orb2023.output.time=orb2023.output.time-datediff;
orb2024=load('orbital_2024.mat');orb2024.output.time=orb2024.output.time-datediff;

%%
    
timesteps=output.Collection.SAL.date-8/24;

    for site=1:length(sitenames)
        disp(sitenames{site});
        tmp=output.(sitenames{site});

        data2csv.SAL=tmp.SAL.bottom;
        data2csv.TEMP=tmp.TEMP.bottom;

        tmp1=tmp.V_x.bottom;
        tmp2=tmp.V_y.bottom;
        data2csv.VT=sqrt(tmp1.^2+tmp2.^2);
        clear tmp1 tmp2;

        PAR=tmp.WQ_DIAG_TOT_PAR.surface;
        data2csv.LIGHT=tmp.WQ_DIAG_TOT_LIGHT.bottom;

        tmp1=tmp.WQ_DIAG_TOT_EXTC.profile;
        data2csv.EXTC=mean(tmp1,1)*0.5;
        clear tmp1;
        data2csv.Depth=depth.output.(sitenames{site}).D;

        for i=1:length(data2csv.Depth)
            tmp2(i)=exp(-data2csv.EXTC(i)*(data2csv.Depth(i)-0.5));
        end
        data2csv.LIGHTperc=tmp2;
        data2csv.PARperc=tmp2;
        data2csv.PAR=PAR.*tmp2;

        for t=1:length(timesteps)
            if timesteps(t)<datenum(2023,1,1)
                tmpdate=orb2022.output.time;
                ind0=find(abs(tmpdate-timesteps(t))==min(abs(tmpdate-timesteps(t))));
                data2csv.ORBITAL(t)=orb2022.output.ubot(site,ind0);
            elseif timesteps(t)<datenum(2024,1,1)
                tmpdate=orb2023.output.time;
                ind0=find(abs(tmpdate-timesteps(t))==min(abs(tmpdate-timesteps(t))));
                data2csv.ORBITAL(t)=orb2023.output.ubot(site,ind0);
            else
                tmpdate=orb2024.output.time;
                ind0=find(abs(tmpdate-timesteps(t))==min(abs(tmpdate-timesteps(t))));
                data2csv.ORBITAL(t)=orb2024.output.ubot(site,ind0);
            end
        end

        data2csv.TAUB=tmp.WQ_DIAG_NCS_D_TAUB.bottom;

        data2csv.WVHT=tmp.WVHT;
        data2csv.WVDIR=tmp.WVDIR;
        data2csv.WVPER=tmp.WVPER;
        data2csv.Date=timesteps;

    outfile=[outDir,'extracted_2023_combined_step2_',sitenames{site},'_extc_scale.mat'];
    save(outfile,'data2csv','-mat','-v7.3');clear data2csv;


    end