clear; close all;

lowResNC='W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\outputs\results\csiem_v1_A001_20220101_20221231_WQ_lowRes_met.nc';
optResNc='W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\outputs\results\csiem_v1_B009_20130101_20131231_WQ_WQ.nc';

ICf='W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\gis_repo\2_benthic\ecology\csiem_aed_benthic_map_B009.csv';
outfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\gis_repo\2_benthic\ecology\csiem_aed_benthic_map_A001.csv';
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

datopt = tfv_readnetcdf(optResNc,'timestep',1);
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

vars={'MAC_seagrass','NCS_fs1','PHY_mpb'};

for vv=1:length(vars)
    disp(vars{vv});
    cdata=data.(vars{vv});
    
    F=scatteredInterpolant(xxo, yyo, double(cdata));
    outdata.(vars{vv})=F(xx,yy);
                
end


% %%
% 
% fileID = fopen(outfile,'w');
% fprintf(fileID,'%s\n','ID,MAC_seagrass,NCS_fs1,PHY_mpb');
% 
% for ii=1:length(xx)
%     fprintf(fileID,'%6d,',ii);
%     fprintf(fileID,'%6.4f,',outdata.MAC_seagrass(ii));
%     fprintf(fileID,'%6.4f,',outdata.NCS_fs1(ii));
%     fprintf(fileID,'%6.4f\n',outdata.PHY_mpb(ii));
% end
% 
% fclose(fileID);