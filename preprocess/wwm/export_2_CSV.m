%% export to CSV

load WWM_REG_2010-2022.mat;

allsites=fieldnames(outputALL);
vars={'WVDIR','WVHT','WVPER'};

for ss=1:length(allsites)
    disp(allsites{ss});
    fileID = fopen(['WWM_REG_',allsites{ss},'.csv'],'w');
    fprintf(fileID,'%s\n','Date,X,Y,WVHT,WVDIR,WVPER');
    for i=1:length(outputALL.(allsites{ss}).(vars{1}).Data)
        fprintf(fileID,'%s,',datestr(outputALL.(allsites{ss}).(vars{1}).Date(i),'dd/mm/yyyy HH:MM:SS'));
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).(vars{1}).X);
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).(vars{1}).Y);
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).WVHT.Data(i));
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).WVDIR.Data(i));
        fprintf(fileID,'%4.6f\n',outputALL.(allsites{ss}).WVPER.Data(i));
    
    end
    fclose(fileID);
end

%% export to CSV

load WWM_CS_2010-2022.mat;

allsites=fieldnames(outputALL);
vars={'WVDIR','WVHT','WVPER'};

for ss=1:length(allsites)
    disp(allsites{ss});
    fileID = fopen(['WWM_CS_',allsites{ss},'.csv'],'w');
    fprintf(fileID,'%s\n','Date,X,Y,WVHT,WVDIR,WVPER');
    for i=1:length(outputALL.(allsites{ss}).(vars{1}).Data)
        fprintf(fileID,'%s,',datestr(outputALL.(allsites{ss}).(vars{1}).Date(i),'dd/mm/yyyy HH:MM:SS'));
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).(vars{1}).X);
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).(vars{1}).Y);
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).WVHT.Data(i));
        fprintf(fileID,'%4.6f,',outputALL.(allsites{ss}).WVDIR.Data(i));
        fprintf(fileID,'%4.6f\n',outputALL.(allsites{ss}).WVPER.Data(i));
    
    end
    fclose(fileID);
end