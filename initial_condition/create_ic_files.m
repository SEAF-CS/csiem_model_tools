clear; close all;

ncfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\tests_OBC_2023_WQ.nc';
time2s=datenum(2023,11,1);

dat = tfv_readnetcdf(ncfile,'time',1);
timesteps = dat.Time;

dat = tfv_readnetcdf(ncfile,'timestep',1);
clear funcions

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

surf_cellsHR=dat.idx3(dat.idx3 > 0);
bottom_cellsHR(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cellsHR(length(dat.idx3)) = length(dat.idx3);

vars={'NCS_ss1',...
      'OXY_oxy',...
      'NIT_amm',...
      'NIT_nit',...
      'PHS_frp',...
      'PHS_frp_ads',...
      'OGM_doc',...
      'OGM_poc',...
      'OGM_don',...
      'OGM_pon',...
      'OGM_dop',...
      'OGM_pop',...
      'PHY_grn',...
      'PHY_pico',...
      'PHY_mdiat',...
      'PHY_dino',...
      'TRC_tr1',...
      'TRC_tr2',...
      'TRC_tr3',...
      'TRC_tr4',...
      'TRC_age'};
%%

ind0=find(abs(timesteps-time2s)==min(abs(timesteps-time2s)));
dat = tfv_readnetcdf(ncfile,'timestep',ind0);

header='ID,WL,U,V,SAL,TEMP,TRACE_1,WQ_1,WQ_2,WQ_3,WQ_4,WQ_5,WQ_6,WQ_7,WQ_8,WQ_9,WQ_10,WQ_11,WQ_12,WQ_13,WQ_14,WQ_15,WQ_16,WQ_17,WQ_18,WQ_19,WQ_20,WQ_21';

varnames={'V_x','V_y','SAL','TEMP'};
data2ic.H=dat.H;

for i=1:length(vars)
    varnames{i+4}=['WQ_',upper(vars{i})];
end

for v=1:length(varnames)
    tmp=dat.(varnames{v});
    data2ic.(varnames{v})=tmp(surf_cellsHR);
end

fileID = fopen('initical_condition_2D_Nov.csv','w');
fprintf(fileID,'%s\n',header);

for j=1:length(dat.idx3)
    fprintf(fileID,'%6d',j);
    fprintf(fileID,',%4.4f',data2ic.H(j));

    for v=1:4 %length(varnames)
        fprintf(fileID,',%4.4f',data2ic.(varnames{v})(j));
    end

    fprintf(fileID,',%4.4f',0);

    for v=5:21 %length(varnames)
        fprintf(fileID,',%4.4f',data2ic.(varnames{v})(j));
    end

    fprintf(fileID,'%s\n','0,0,0,0,0');
end

fclose(fileID);