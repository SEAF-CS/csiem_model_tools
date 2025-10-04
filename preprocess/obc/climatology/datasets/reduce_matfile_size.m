%%
clear; close all;

matfile='W:\csiem\csiem-marvl-dev\data\agency\csiem_DWER_public.mat';
%matfile='W:\csiem\csiem-marvl-dev\data\agency\csiem_IMOS_public.mat';

data=load(matfile);

%%
intv=50;

sites=fieldnames(data.csiem);

for ss=1:length(sites)
    vars=fieldnames(data.csiem.(sites{ss}));

    for vv=1:length(vars)
        csiem.(sites{ss}).(vars{vv})=data.csiem.(sites{ss}).(vars{vv});

        vdata=data.csiem.(sites{ss}).(vars{vv}).Data;
        if length(vdata)>5000
            disp([sites{ss},': ',vars{vv}]);
            csiem.(sites{ss}).(vars{vv}).Date=data.csiem.(sites{ss}).(vars{vv}).Date(1:intv:end);
            csiem.(sites{ss}).(vars{vv}).Data=data.csiem.(sites{ss}).(vars{vv}).Data(1:intv:end);
            csiem.(sites{ss}).(vars{vv}).Data_Raw=data.csiem.(sites{ss}).(vars{vv}).Data_Raw(1:intv:end);
            csiem.(sites{ss}).(vars{vv}).Depth=data.csiem.(sites{ss}).(vars{vv}).Depth(1:intv:end);
            if isfield(data.csiem.(sites{ss}).(vars{vv}),'oDepth')
            csiem.(sites{ss}).(vars{vv}).oDepth=data.csiem.(sites{ss}).(vars{vv}).oDepth(1:intv:end);
            end
        end

    end
end

matfileOut='W:\csiem\csiem-marvl-dev\data\agency\csiem_DWER_public_reduced50.mat';
%matfileOut='W:\csiem\csiem-marvl-dev\data\agency\csiem_IMOS_public_reduced50.mat';
save(matfileOut,'csiem','-mat','-v7.3')

