clear; close all;

shpFile='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\gis_repo\2_benthic\materials\CSOA_Ranae_SGspp_final_final.shp';
shp=shaperead(shpFile);
outFile='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\gis_repo\2_benthic\materials\CSOA_theme21_benthic_zones_final.shp';


% Material zone orders:
% material == 1! entire model domain 
% material == 16! swan river
% material == 21, 22, 23, 24, 25, 26, 27! sed grainsize
% material == 61! soft substrate sand
% material == 68, 89! hard substrate reef (68 is from previous version and outside CSOA (from various sources), 89 is from Ranae's latest version and in CSOA only)
% material == 70! mixed substrate
% material == 60! Seagrass (Swan River)(no species info)
% material == 66! Seagrass (Perennial) (no species info)
% material == 80,81,82,83,84,85,86,87! Seagrass (with species info)
% material == 59! artificial structure

orders  =[1 16 61 68 70 21:27 60 90:95 59];
%fs1_zone=[0 0.4 0.4:-0.05:0.1 0.05 0   0 0.01 0  0 0 0 0 0 0 0 0 0 0];
%MPB_zone=[0 10 10:-1.25:2.5   0.00 50 50 0.00 0  0 0 0 0 0 0 0 0 0 0]; 

for ss=1:length(shp)
    matid(ss)=shp(ss).Material;
end

for oo=1:length(orders)
    k=find(matid==orders(oo));
    shp2(oo)=shp(k);
%     processOrder(oo)=k;
%     neworders(oo)=shp(k).Material;
%     shp(k).fs1=fs1_zone(oo);
%     shp(k).MPB=MPB_zone(oo);
end

shapewrite(shp2,outFile)

