clear; close all;

load('W:\csiem\csiem-marvl-dev\data\agency\csiem_DWER_public_reduced50.mat');

sites=fieldnames(csiem);
%%
for ss=1:length(sites)
    Index = find(contains(sites{ss},'6142985'));

    if ~isempty(Index)
    disp(sites{ss});
    end
end
%%
inc=1;

for ss=1:length(sites)
    disp(sites{ss});
    vars=fieldnames(csiem.(sites{ss}));

    for vv=1:length(vars)
        allvars{inc}=vars{vv};
        inc=inc+1;
    end
end

%% sort vars

[uc, ~, idc] = unique(allvars);
% 
% fileID = fopen('IMOS_vars.csv','w');
% fprintf(fileID,'%s\n','vars,counts');
% for i=1:length(uc)
%     fprintf(fileID,'%s,',uc{i});
%     fprintf(fileID,'%6.2f\n',sum(idc==i));
% end
% fclose(fileID);

%% check sites

fileID = fopen('DWER_vars_sites.csv','w');
fprintf(fileID,'%s\n','vars,sitename,X,Y');


varsID=[5 7 20 22 23 24 26:33 ];

for vv=1:length(varsID)
    var2s=uc{varsID(vv)};

    for ss=1:length(sites)
    
    vars=fieldnames(csiem.(sites{ss}));

    Index = find(contains(vars,var2s));

    if ~isempty(Index) && isempty(find(contains(vars,'AIR')))
        fprintf(fileID,'%s,',var2s);
        fprintf(fileID,'%s,',sites{ss});
        fprintf(fileID,'%6.6f,',csiem.(sites{ss}).(var2s).X);
        fprintf(fileID,'%6.6f\n',csiem.(sites{ss}).(var2s).Y);
    end
    end

end

fclose(fileID);

%% export data

for vv=1:length(varsID)
    var2s=uc{varsID(vv)};
    data=[];
    for ss=1:length(sites)
    
    vars=fieldnames(csiem.(sites{ss}));

    Index = find(contains(vars,var2s));

    if ~isempty(Index) && isempty(find(contains(vars,'AIR')))
        data.(sites{ss}).(var2s)=csiem.(sites{ss}).(var2s);
    end
    end

    save(['DWER_data_',var2s,'.mat'],'data','-mat');
end