
clear; close all;
f3='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\model_runs\WQ_dev\check\csiem_v1_C001_20220101_20221231_WQ_highRes_dredge_MZ13_mesh_check_R.shp';
shp3=shaperead(f3);

%%
inc=1;
inc2=0;

for ss=1:length(shp3)
    if mod(ss,10000)==0
        disp(ss);
    end
    idx2=str2num(shp3(ss).IDX2);

    if idx2==inc 
        shp32(inc)=shp3(ss);
        inc=inc+1;
    end

end

shapewrite(shp32,'csiem_v1_C001_20220101_20221231_WQ_highRes_dredge_MZ13_mesh_check_R_reduced.shp')