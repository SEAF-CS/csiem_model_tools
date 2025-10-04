clear; close all;

for i=1:6
    infile=['Polygons_',num2str(i),'_MultiPolygon.shp'];
    tmpshp=shaperead(infile);
    if i==1
        shp2(1)=tmpshp(1);
    else
        shp2(i)=tmpshp(1);
    end
end

shapewrite(shp2,'.\merged_6OBC.shp')
% 
% %% create new shp file for 6 polygons
% 
% shp2=shp;
% shp2(10).ID=10;
% shp2(11).ID=11;
% 
% sl=length(shp);
% 
% ids=[1 4 11 16 19 22 23];
% 
% for s=1:6
%     
%     newX=shp(1).X(ids(s):ids(s+1));
%     newY=shp(1).Y(ids(s):ids(s+1));
% 
%     BoundingBox=[min(newX),min(newY);max(newX),max(newY)];
%     newXX=[newX,NaN];
%     newYY=[newY,NaN];
% 
%     if s==1
%         shp2(1).BoundingBox=BoundingBox;
%     shp2(1).X=newXX;
%     shp2(1).Y=newYY;
%    % shp2(1).ID=sl+s;
%     else
%     shp2(sl+s-1)=shp2(1);
% 
%     shp2(sl+s-1).BoundingBox=BoundingBox;
%     shp2(sl+s-1).X=newXX;
%     shp2(sl+s-1).Y=newYY;
%     shp2(sl+s-1).ID=sl+s-1;
%     end
% end
% 
% shapewrite(shp2,'W:\csiem\Model\TFV\csiem_model_tfvaed_1.1\gis_repo\1_domain\nodestrings\ns_005_nutrient_6OBC.shp')

