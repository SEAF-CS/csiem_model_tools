clear; close all;
%addpath(genpath('W:\csiem\csiem-marvl\'))

ncfile(1).name='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_OBC_2023_waves_scale_WQ.nc';

allvars = tfv_infonetcdf(ncfile(1).name);
NumBands=16;
inc=1;

for i=1:length(allvars)
     var=allvars{i};

     if strfind(var,'WQ_DIAG_OAS_')>0
         loadnames{inc}=var; inc=inc+1;
     end
end

loadnames{inc}='WQ_DIAG_PHY_TCHLA';inc=inc+1;
loadnames{inc}='WQ_OGM_POC';inc=inc+1;
loadnames{inc}='WQ_OGM_DOC';inc=inc+1;
loadnames{inc}='WQ_NCS_SS1';inc=inc+1;

loadnames2=loadnames';

%%

outDir='.\';

if ~exist(outDir,'dir')
    mkdir(outDir);
end

sitenames={'Freshwater_Bay','Mullaloo_Beach','West_Rottnest','Owen_Anchorage',...
    'Kwinana_Shelf','Deep_Basin','Mangles_Bay','East_Garden_Island','Validation'};

for ll=1:length(loadnames)
    tic;

    loadname=loadnames{ll};
    disp(['loading ',loadname,' ...']);
    
    infile=[outDir,'extracted_OASIM_2023_',loadname,'.mat'];
    data=load(infile);
    
    for site=1:length(sitenames)
        disp(sitenames{site});
        tmp=data.output.(sitenames{site}).(loadname);

        output.(sitenames{site}).(loadname)=tmp;
    end

    toc;
end

outfile=[outDir,'extracted_2023_combined_v6.mat'];
save(outfile,'output','-mat','-v6');