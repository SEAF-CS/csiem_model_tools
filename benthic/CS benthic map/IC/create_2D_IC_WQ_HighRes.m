clear; close all;

lowResNC='W:\csiem\Model\TFV\csiem_model_tfvaed_1.5\outputs\results\csiem_A001_20221101_20240401_WQ.nc';
HighResNc='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\outputs\results\csiem_v1_C001_20220101_20221231_WQ_highRes_dredge_highRes.nc';

ICf='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\includes\ic\initical_condition_2D_Nov.csv';
outfile='.\benthic_ecology_csiem20\initical_condition_2D_Nov_C001.csv';
% dat = tfv_readnetcdf(infile,'time',1);
% timesteps = dat.Time;
% 
% t0=datenum(2013,3,21);
% 
% ind=find(abs(timesteps-t0)==min(abs(timesteps-t0)));


data = [];

fid = fopen(ICf,'rt');

sLine = fgetl(fid);

headers = regexp(sLine,',','split');
headers = regexprep(headers,'\s','');
EOF = 0;
inc = 1;
while ~EOF
    
    sLine = fgetl(fid);
    
    if sLine == -1
        EOF = 1;
    else
        dataline = regexp(sLine,',','split');
        
        for ii = 1:length(headers)
            
            
            switch upper(headers{ii})
                
                case 'ISOTIME'
                    try
                    data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy HH:MM');
                    catch
                       data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy');
                    end
                case 'DATE'
                    try
                    data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy HH:MM');
                    catch
                       data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy');
                    end
                otherwise
                    data.(headers{ii})(inc,1) = str2double(dataline{ii});
            end
        end
        inc = inc + 1;
    end
end
    
    %%

dat = tfv_readnetcdf(lowResNC,'timestep',1);
xx=dat.cell_X;yy=dat.cell_Y;

datopt = tfv_readnetcdf(HighResNc,'timestep',1);
xxo=datopt.cell_X;yyo=datopt.cell_Y;




%%
% clear funcions

% vert(:,1) = dat.node_X;
% vert(:,2) = dat.node_Y;
% 
% faces = dat.cell_node';
% 
% %--% Fix the triangles
% faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);
% 
% surf_cells=dat.idx3(dat.idx3 > 0);
% bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
% bottom_cells(length(dat.idx3)) = length(dat.idx3);
% 
% fields=fieldnames(dat);
% f2=fields(21:39);
%     
% header='ID,WL,U,V,Sal,Temp,TRACE_1,WQ_1,WQ_2,WQ_3,WQ_4,WQ_5,WQ_6,WQ_7,WQ_8,WQ_9,WQ_10,WQ_11,WQ_12,WQ_13,WQ_14,WQ_15,WQ_16,WQ_17,WQ_18,WQ_19,WQ_20,WQ_21,WQ_22'; 
% 
% cellx=dat.cell_X;
% celly=dat.cell_Y;
% 
% infile2='csiem_100_A_20130101_20130601_WQ_009_waves_nutirent_trc_GW_HighRes.nc';
% cellx2=ncread(infile2,'cell_X');
% celly2=ncread(infile2,'cell_Y');

vars={'WL','U','V','SAL','TEMP','TRACE_1','WQ_1','WQ_2','WQ_3','WQ_4','WQ_5','WQ_6','WQ_7','WQ_8','WQ_9','WQ_10','WQ_11','WQ_12','WQ_13','WQ_14','WQ_15','WQ_16','WQ_17','WQ_18','WQ_19','WQ_20','WQ_21'};

for vv=1:length(vars)
    disp(vars{vv});
    cdata=data.(vars{vv});
    
    F=scatteredInterpolant(xx, yy, double(cdata));
    outdata.(vars{vv})=F(xxo,yyo);
                
end


%%

fileID = fopen(outfile,'w');
fprintf(fileID,'%s\n','ID,WL,U,V,SAL,TEMP,TRACE_1,WQ_1,WQ_2,WQ_3,WQ_4,WQ_5,WQ_6,WQ_7,WQ_8,WQ_9,WQ_10,WQ_11,WQ_12,WQ_13,WQ_14,WQ_15,WQ_16,WQ_17,WQ_18,WQ_19,WQ_20,WQ_21');

for ii=1:length(xxo)
    fprintf(fileID,'%6d',ii);
    for vv=1:length(vars)
        fprintf(fileID,',%6.4f',outdata.(vars{vv})(ii));
    end
    fprintf(fileID,'%s\n','');
end

fclose(fileID);

%%

%dat = tfv_readnetcdf(ncfile,'timestep',1);
vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

surf_cells=dat.idx3(dat.idx3 > 0);
bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cells(length(dat.idx3)) = length(dat.idx3);

vert2(:,1) = datopt.node_X;
vert2(:,2) = datopt.node_Y;

faces2 = datopt.cell_node';

%--% Fix the triangles
faces2(faces2(:,4)== 0,4) = faces2(faces2(:,4)== 0,1);

surf_cells2=datopt.idx3(datopt.idx3 > 0);
bottom_cells2(1:length(datopt.idx3)-1) = datopt.idx3(2:end) - 1;
bottom_cells2(length(datopt.idx3)) = length(datopt.idx3);


%%
hfig = figure('visible','on','position',[304         166         1200        675]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 13.5]);

for vv=1:length(vars)
    clf;
subplot(1,2,1);
patFig = patch('faces',faces,'vertices',vert,'FaceVertexCData',data.(vars{vv}));shading flat;
axis equal;
colorbar;

subplot(1,2,2);
patFig = patch('faces',faces2,'vertices',vert2,'FaceVertexCData',outdata.(vars{vv}));shading flat;
axis equal;
colorbar;

img_name =['.\benthic_ecology_csiem20\HighRes_',vars{vv},'.png'];
saveas(gcf,img_name);

end