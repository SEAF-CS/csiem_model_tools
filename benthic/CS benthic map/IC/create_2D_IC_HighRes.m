

infile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.0\tfvaed_1.0\outputs\results\csiem_100_A_20130101_20130601_WQ_009_waves_WQ.nc';

dat = tfv_readnetcdf(infile,'time',1);
timesteps = dat.Time;

t0=datenum(2013,3,21);

ind=find(abs(timesteps-t0)==min(abs(timesteps-t0)));

dat = tfv_readnetcdf(infile,'timestep',ind);
clear funcions

vert(:,1) = dat.node_X;
vert(:,2) = dat.node_Y;

faces = dat.cell_node';

%--% Fix the triangles
faces(faces(:,4)== 0,4) = faces(faces(:,4)== 0,1);

surf_cells=dat.idx3(dat.idx3 > 0);
bottom_cells(1:length(dat.idx3)-1) = dat.idx3(2:end) - 1;
bottom_cells(length(dat.idx3)) = length(dat.idx3);

fields=fieldnames(dat);
f2=fields(21:39);
    
header='ID,WL,U,V,Sal,Temp,TRACE_1,WQ_1,WQ_2,WQ_3,WQ_4,WQ_5,WQ_6,WQ_7,WQ_8,WQ_9,WQ_10,WQ_11,WQ_12,WQ_13,WQ_14,WQ_15,WQ_16,WQ_17,WQ_18,WQ_19,WQ_20,WQ_21,WQ_22'; 

cellx=dat.cell_X;
celly=dat.cell_Y;

infile2='csiem_100_A_20130101_20130601_WQ_009_waves_nutirent_trc_GW_HighRes.nc';
cellx2=ncread(infile2,'cell_X');
celly2=ncread(infile2,'cell_Y');

for ff=1:length(f2)
    disp(f2{ff});
    cdata=dat.(f2{ff})(surf_cells);
    
    F=scatteredInterpolant(cellx, celly, double(cdata));
    outdata.(f2{ff})=F(cellx2,celly2);
                
end
%vars={'SAL','TEMP',