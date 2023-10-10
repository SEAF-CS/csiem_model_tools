
clear; close all;

sites={'AWAC1','AWAC2','Cath1','Cath2','DC','Stirling','Parmelia','Rottnest','S01','S02'};
agencies={'CCL','CCL','CoC','CoC','FPA','FPA','FPA','DoT','JPPL','JPPL'};
depths=[-14.6,-7.4,-6.5,-8.5,-13.0,-13.8,-9.0,-73.0,-10,-18];
lons  =[115.704160,  115.679512, 115.728092, 115.745646, 115.686667, 115.744336, 115.701664, 115.407778, 115.762710, 115.730832];
lats  =[-32.079398,  -32.095191, -32.078775, -32.090541, -31.977779, -32.203214, -32.130005, -32.094167, -32.200942, -32.180925];
%InGridA =[1 1 1 1 1 1 1 1 1 1];
%InGridB =[1 1 1 1 1 1 1 0 1 1];
%InGridC =[0 0 0 0 0 1 0 0 1 1];
inWWMGRE=[1 1 1 1 1 1 1 1 1 1];
inWWMLOC=[1 1 1 1 1 1 1 0 1 1];
%inExpGdA=[1 1 1 1 1 1 1 1 1 1];
%inExpGdB=[1 1 1 1 1 1 1 0 1 1];
%inExpGdC=[0 0 0 0 0 1 0 0 1 1];


stdvars={'DIR','HS','TPER'};
vars={'WVDIR','WVHT','WVPER'};

%% export WWM regional grids

outputALL=[];
years2pro={'2010','2011','2012','2013','2014','2015','2016','2017','2018',...
    '2019','2020','2021','2022'};

for yy=1:length(years2pro)
    
    infile=['WWM_REG_sites_',years2pro{yy},'.mat'];
    
    disp(infile);
    load(infile);
    
    if yy==1

        allsites=fieldnames(output);
        for ss=1:length(allsites)
            Index=find(contains(sites,allsites{ss}));
            disp(sites{Index});
            for vv=1:length(stdvars)
                outputALL.(allsites{ss}).(vars{vv}).Data=output.(allsites{ss}).(stdvars{vv});
                outputALL.(allsites{ss}).(vars{vv}).Date=output.(allsites{ss}).time';
                outputALL.(allsites{ss}).(vars{vv}).Depth=output.(allsites{ss}).(stdvars{vv})*0;
                
                outputALL.(allsites{ss}).(vars{vv}).X=lons(Index);
                outputALL.(allsites{ss}).(vars{vv}).Y=lats(Index);
            end
        end
    else
        allsites=fieldnames(output);
        
        for ss=1:length(allsites)
            Index=find(contains(sites,allsites{ss}));
            disp(sites{Index});

            for vv=1:length(stdvars)
                outputALL.(allsites{ss}).(vars{vv}).Data= ...
                    [outputALL.(allsites{ss}).(vars{vv}).Data, output.(allsites{ss}).(stdvars{vv})];
                outputALL.(allsites{ss}).(vars{vv}).Date= ...
                    [outputALL.(allsites{ss}).(vars{vv}).Date, output.(allsites{ss}).time'];
                outputALL.(allsites{ss}).(vars{vv}).Depth= ...
                    [outputALL.(allsites{ss}).(vars{vv}).Depth, output.(allsites{ss}).(stdvars{vv})*0];
                
             %   outputALL.(allsites{ss}).(stdvars{vv})=[outputALL.(allsites{ss}).(stdvars{vv}),output.(allsites{ss}).(stdvars{vv})];
            end
        end
        
    end
end

save('WWM_REG_2010-2022.mat','outputALL','-mat','-v7.3');

%% export WWM CS grids

outputALL=[];
years2pro={'2010','2011','2012','2013','2014','2015','2016','2017','2018',...
    '2019','2020','2021','2022'};

for yy=1:length(years2pro)
    
    infile=['WWM_CS_sites_',years2pro{yy},'.mat'];
    
    disp(infile);
    load(infile);
    
    if yy==1

        allsites=fieldnames(output);
        for ss=1:length(allsites)
            Index=find(contains(sites,allsites{ss}));
            disp(sites{Index});
            for vv=1:length(stdvars)
                outputALL.(allsites{ss}).(vars{vv}).Data=output.(allsites{ss}).(stdvars{vv});
                outputALL.(allsites{ss}).(vars{vv}).Date=output.(allsites{ss}).time';
                outputALL.(allsites{ss}).(vars{vv}).Depth=output.(allsites{ss}).(stdvars{vv})*0;
                
                outputALL.(allsites{ss}).(vars{vv}).X=lons(Index);
                outputALL.(allsites{ss}).(vars{vv}).Y=lats(Index);
            end
        end
    else
        allsites=fieldnames(output);
        
        for ss=1:length(allsites)
            Index=find(contains(sites,allsites{ss}));
            disp(sites{Index});

            for vv=1:length(stdvars)
                outputALL.(allsites{ss}).(vars{vv}).Data= ...
                    [outputALL.(allsites{ss}).(vars{vv}).Data, output.(allsites{ss}).(stdvars{vv})];
                outputALL.(allsites{ss}).(vars{vv}).Date= ...
                    [outputALL.(allsites{ss}).(vars{vv}).Date, output.(allsites{ss}).time'];
                outputALL.(allsites{ss}).(vars{vv}).Depth= ...
                    [outputALL.(allsites{ss}).(vars{vv}).Depth, output.(allsites{ss}).(stdvars{vv})*0];
                
             %   outputALL.(allsites{ss}).(stdvars{vv})=[outputALL.(allsites{ss}).(stdvars{vv}),output.(allsites{ss}).(stdvars{vv})];
            end
        end
        
    end
end

save('WWM_CS_2010-2022.mat','outputALL','-mat','-v7.3');

