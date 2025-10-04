SAL2=SAL;
SAL=ncread(romsfile,'salinity');

%%
for t=11:27
t0=datenum(2022,t,2);

ind0=find(abs(time-t0)==min(abs(time-t0)));
s1=squeeze(SAL(:,:,1,ind0));
s2=squeeze(SAL2(:,:,1,ind0));

dvec3=datevec(t0);
tmpind=find(dvec2(:,1)==dvec3(1) & dvec2(:,2)==dvec3(2));
fact1=bias.offshore.factor(tmpind);
fact2=bias.nearshore.factor(tmpind);

 k=1;


            tmpsal=s1;
          %  tmpsal=squeeze(tmpsal(:,:,1,1));
            tmpsal2=tmpsal;
        for i=1:6


            if (i==1 || i==6)
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*fact2;
            else
                tmpsal2(inds.(['poly',num2str(i)]))=tmpsal(inds.(['poly',num2str(i)]))*fact1;
            end

        end


hfig3 = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 42 12]);
clf;

subplot(1,4,1);
pcolor(LON2', LAT2', s1); shading flat;
colorbar;
title('original ROMS');
axis equal;
set(gca,'xlim',[114.3 115.8],'ylim',[-33.7 -30.5]);

subplot(1,4,2);
pcolor(LON2', LAT2', s2); shading flat;
colorbar;
title('bias corrected');
axis equal;
set(gca,'xlim',[114.3 115.8],'ylim',[-33.7 -30.5]);

subplot(1,4,3);
pcolor(LON2', LAT2', s2-s1); shading flat;
colorbar;
title('difference');
axis equal;
set(gca,'xlim',[114.3 115.8],'ylim',[-33.7 -30.5]);

subplot(1,4,4);
pcolor(LON2', LAT2', tmpsal2-s1); shading flat;
colorbar;
title('difference2');
axis equal;
set(gca,'xlim',[114.3 115.8],'ylim',[-33.7 -30.5]);

img_name =['ROMS_2023_Benchmarking_check_',datestr(t0,'yyyymmdd'),'.png'];

saveas(gcf,img_name);
end