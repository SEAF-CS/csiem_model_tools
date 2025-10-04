clear; close all;

load extracted_for_Currents.mat;

time=output.CS1.V_x.date;
depth=output.CS1.V_x.depths;

vx=output.CS1.V_x.profile;
vy=output.CS1.V_y.profile;

cs=sqrt(vx.^2+vy.^2);
cd=atan2(vy,vx);
cd2=rad2deg(cd);
cd2(vy<0)=cd2(vy<0)+360;
% 
% for i=1:cd2
%     if vy(i)<0
%         if vx(i)>0
%             cd2(i)=cd2(i)+360;
%         else
%             cd2(vy<0)=cd2(vy<0)+180;

hfig = figure('visible','on','position',[304         166         1200        675]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 24 13.5]);

datearray=datenum(2022,4:7,1);

subplot(2,1,1)
pcolor(time,depth,cs);shading flat;
colorbar;
set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mmm/yyyy'));
title('(a) Current speed (m/s)');
ylabel('Depth (m)')

subplot(2,1,2)
pcolor(time,depth,cd2);shading flat;
colorbar;
set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'dd/mmm/yyyy'));
title('(b) Current Direction (degrees toward)');
ylabel('Depth (m)')

img_name ='./CS1_current_profile.png';
    
    saveas(gcf,img_name);
