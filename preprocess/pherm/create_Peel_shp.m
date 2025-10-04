clear; close all;

shp=shaperead('W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\gis_repo\1_domain\nodestrings\ns_005_nutrient.shp');
shp2=shp;

shp2(12)=shp2(11);

%ND 25975 1.15708426e+002 -3.25198933e+001 
%ND 26123 1.15713136e+002 -3.25200703e+001 
box=[115.70842, -32.51989; 115.71313, -32.52007];
X=[115.70842 115.71313 NaN];
Y=[-32.51989 -32.52007 NaN];
ID=12;

shp2(10).ID=10;
shp2(11).ID=11;
shp2(12).BoundingBox=box;
shp2(12).X=X;
shp2(12).Y=Y;
shp2(12).ID=12;

outfile='W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\gis_repo\1_domain\nodestrings\ns_005_nutrient_Peel.shp';
shapewrite(shp2,outfile);