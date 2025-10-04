%%
clear; close all;

depths=0:0.1:12;  % depth array
minBiomass=0;     % min biomass
maxBiomass=700;   % max biomass
minDepth  =2;     % min depth above which is max biomass;
maxDepth  =10;     % max depth below which is 0 biomass;
Biomass=zeros(size(depths));  % allocate biomass array

% loop through the depth for biomass
for i=1:length(depths)
        scale=12/(maxDepth-minDepth);
        offset=-6/scale-minDepth;
        a=(depths(i)+offset)*scale;
        Biomass(i)=minBiomass+exp(-a)./(1+exp(-a))*(maxBiomass-minBiomass);
end

%% load in field data

data=[1.6124882	897.2029;...
    3.9898624	645.3385;...
    5.699007	417.43436;...
    6.498638	143.36446;...
    8.315806	32.56669;...
    9.037583	16.377348;...
    1.6370096	654.98944;...
    4.0166	645.3176;...
    5.6709824	276.8273;...
    6.5250897	112.09292;...
    8.315806	32.56669;...
    9.037583	16.377348;...
    1.6266667	519.3798;...
    4	682.17053;...
    5.7066665	558.1395;...
    6.56	131.78294;...
    8.293333	15.503876;...
    9.013333	15.503876];

for j=1:size(data,1)
    bb2(j)=interp1(depths,Biomass,data(j,1));
end
%%
gcf=figure;
set(gcf,'Position',[100 100 800 500]);
set(0,'DefaultAxesFontSize',15);

clf;

plot(depths,Biomass);
hold on;
scatter(data(:,1),data(:,2));
hold on;

[r b]=regression(data(:,2),bb2','one')
legend('fit','data');
text(9.5,300,['r=',num2str(r,'%4.4f')]);

xlabel('depth (m)')
ylabel('biomass (gDW/m2)')

print(gcf,'Biomass_vs_depth.png','-dpng');