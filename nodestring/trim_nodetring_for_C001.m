
clear; close all;

ndfile='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\gis_repo\1_domain\nodestrings\ns_005_nutrient_6OBC.shp';
ndoutfile='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\gis_repo\1_domain\nodestrings\ns_005_nutrient_6OBC_C001.shp';

nd=shaperead(ndfile);

inds=[1:3 12:16];

for i=1:length(inds)
    shp2(i)=nd(inds(i));
end

shapewrite(shp2,ndoutfile)


