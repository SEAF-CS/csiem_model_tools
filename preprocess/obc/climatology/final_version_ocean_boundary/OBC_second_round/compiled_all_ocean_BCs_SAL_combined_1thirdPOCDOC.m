
clear; close all;

% AED variable list
%       S(           1 ) AED pelagic(3D) variable: NCS_ss1
%       S(           2 ) AED pelagic(3D) variable: OXY_oxy
%       S(           3 ) AED pelagic(3D) variable: NIT_amm
%       S(           4 ) AED pelagic(3D) variable: NIT_nit
%       S(           5 ) AED pelagic(3D) variable: PHS_frp
%       S(           6 ) AED pelagic(3D) variable: PHS_frp_ads
%       S(           7 ) AED pelagic(3D) variable: OGM_doc
%       S(           8 ) AED pelagic(3D) variable: OGM_poc
%       S(           9 ) AED pelagic(3D) variable: OGM_don
%       S(          10 ) AED pelagic(3D) variable: OGM_pon
%       S(          11 ) AED pelagic(3D) variable: OGM_dop
%       S(          12 ) AED pelagic(3D) variable: OGM_pop
%       S(          13 ) AED pelagic(3D) variable: PHY_grn
%       S(          14 ) AED pelagic(3D) variable: PHY_bga
%       S(          15 ) AED pelagic(3D) variable: PHY_crypt
%       S(          16 ) AED pelagic(3D) variable: PHY_mdiat
%       S(          17 ) AED pelagic(3D) variable: PHY_dino
%       S(          18 ) AED pelagic(3D) variable: TRC_tr1
%       S(          19 ) AED pelagic(3D) variable: TRC_tr2
%       S(          20 ) AED pelagic(3D) variable: TRC_tr3
%       S(          21 ) AED pelagic(3D) variable: TRC_tr4
%       S(          22 ) AED pelagic(3D) variable: TRC_age

compiled_vars={'SAL','SS1','OXY','AMM','NIT','FRP','DOC','POC','CHLA'};
tmp=load('SS\exported_SS.mat');
compiled.SS1=tmp.output;
tmp=load('Dissolved_nutrients\exported_WQ_OXY_OXY.mat');
compiled.OXY=tmp.output;
tmp=load('Dissolved_nutrients\exported_WQ_NIT_AMM.mat');
compiled.AMM=tmp.output;
tmp=load('Dissolved_nutrients\exported_WQ_NIT_NIT.mat');
compiled.NIT=tmp.output;
tmp=load('Dissolved_nutrients\exported_WQ_PHS_FRP.mat');
compiled.FRP=tmp.output;
tmp=load('POC\exported_POC.mat');
compiled.POC=tmp.output;

tmp=load('phytoplankton\exported_Diato.mat');
compiled.DIATOM=tmp.output;
tmp=load('phytoplankton\exported_Dino.mat');
compiled.DINO=tmp.output;
tmp=load('phytoplankton\exported_GREEN.mat');
compiled.GREEN=tmp.output;
tmp=load('phytoplankton\exported_PROKAR.mat');
compiled.PICO=tmp.output;

% 
% 
% 
% for vv=1:length(compiled_vars)
%     inDir=['..\',compiled_vars{vv},'\'];
%     infile=[inDir,'exported_',compiled_vars{vv},'.mat'];
%     data=load(infile);
% 
%     compiled.(compiled_vars{vv})=data.output;
% 
% end

%%
header='Date,TSS,DO,AMM,NIT,FRP,FRPADS,POC,DOC,PON,DON,POP,DOP,DIATOM,DINO,GREEN,PICO,ZEROS,ONES';
time=compiled.SS1.poly1.time;
% 
% SAL1=[36.2 36.7 36.8 36.5 36.3 35.7 35.5 34.8 34.6 34.7 35.5 36];
% SAL2=[35.6 35.7 35.7 35.7 35.6 35.5 35.4 35.3 35.0 35.0 35.2 35.4];
% SAL3=[36.4 37.2 37.1 36.6 36.3 35.7 35.5 35.4 34.7 34.6 35 35.5];

for polys=1:6
    disp(polys);
    fileID = fopen(['ocean_bgc_monthly_1980_2024_poly',num2str(polys),'.csv'],'w');
    fprintf(fileID,'%s\n',header);

    %cal DOC basd on POC using DOC=3.2408POC+3.4973 (mg dm-3, Maciejewska
    %2014)
    tmpdata=compiled.POC.(['poly',num2str(polys)]).data;
%     tmpdata=tmpdata*12/1000;
%     DOC=tmpdata*3.2408+3.4973;
%     DOC=DOC/12*1000;
    DOC=tmpdata*80/14;

    for d=1:length(time)
        fprintf(fileID,'%s,',datestr(time(d),'dd/mm/yyyy HH:MM:SS'));
        tmpvec=datevec(time(d));
% 
%         if (polys==1 || polys==2)
%             fprintf(fileID,'%4.4f,',SAL1(tmpvec(2)));
%         elseif (polys==3 || polys==4)
%             fprintf(fileID,'%4.4f,',SAL2(tmpvec(2)));
%         else
%             fprintf(fileID,'%4.4f,',SAL3(tmpvec(2)));
%         end
%        fprintf(fileID,'%4.4f,',compiled.SAL.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.SS1.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.OXY.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.AMM.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.NIT.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.FRP.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.FRP.(['poly',num2str(polys)]).data(d)*0.1);
        fprintf(fileID,'%4.4f,',compiled.POC.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',DOC(d));
        fprintf(fileID,'%4.4f,',compiled.POC.(['poly',num2str(polys)]).data(d)*16/106);
        fprintf(fileID,'%4.4f,',DOC(d)*16/106);
        fprintf(fileID,'%4.4f,',compiled.POC.(['poly',num2str(polys)]).data(d)*1/106);
        fprintf(fileID,'%4.4f,',DOC(d)*1/106);
        fprintf(fileID,'%4.4f,',compiled.DIATOM.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.DINO.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.GREEN.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%4.4f,',compiled.PICO.(['poly',num2str(polys)]).data(d));
        fprintf(fileID,'%s\n','0,1');
    end


    fclose(fileID);

end

%%


hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);

for polys=1:6
    disp(polys);
    data = tfv_readBCfile(['ocean_bgc_monthly_1980_2024_poly',num2str(polys),'.csv']);

    outdir=['plots_BCs_SAL_combined_poly',num2str(polys)];

    if ~exist(outdir,'dir')
        mkdir(outdir);
    end

    vars=fieldnames(data);
    datearray=datenum(1980:3:2025,1,1);

    for v=2:length(vars)
        clf;

        plot(data.Date,data.(vars{v}));
        set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'yyyy'));
        %  set(gca,'ylim',[215 245]);
        ylabel(vars{v})

        title([vars{v}, ' - poly',num2str(polys)]);

        img_name =[outdir,'\BC_',vars{v},'.png'];

        saveas(gcf,img_name);
    end


end
