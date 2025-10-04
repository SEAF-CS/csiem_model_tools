clear all; close all;

filename = 'National_Outfall_Database.csv';

mkdir('Proc/');

[~,sites]  = xlsread(filename,'G2:G10000');

[~,dates]  = xlsread(filename,'C2:C10000');


[~,vars]  = xlsread(filename,'D2:D10000');

[~,units]  = xlsread(filename,'F2:F10000');

[vals,~]  = xlsread(filename,'E2:E10000');

[lat,~]  = xlsread(filename,'I2:I10000');

[lon,~]  = xlsread(filename,'J2:J10000');




[uvars,ind] = unique(vars);
usites = unique(sites);

mdates = datenum(dates,'dd/mm/yyyy');

for i = 1:length(usites)

    sss = find(strcmpi(sites,usites{i}));

    fid = fopen(['Proc/',usites{i},'_data.csv'],'wt');

    fprintf(fid,'Dates,');

    for j = 1:length(uvars)
        %fprintf(fid,'%s,',[uvars{j},' (',units{ind(j)},')']);
        fprintf(fid,'%s,',uvars{j});
    end
    fprintf(fid,'\n');

    ssmdates = mdates(sss);

    udates = unique(ssmdates);
    
    
    for k = 1:length(udates)
        fprintf(fid,'%4.4f,',udates(k));
        
        ttt = find(strcmpi(sites,usites{i})==1 & mdates == udates(k));


        for j = 1:length(uvars)
            

            ggg = find(strcmpi(vars(ttt),uvars{j})  ==1 );

            if ~isempty(ggg)


                fprintf(fid,'%4.4f,',vals(ttt(ggg)));

            else

                fprintf(fid,'%4.4f,',NaN);
            end
        end
        fprintf(fid,'\n');
    end
    fclose(fid);


    tdata =  readtable(['Proc/',usites{i},'_data.csv']) ;      

    fid = fopen(['Proc/',usites{i},'_tfv.csv'],'wt');

    fprintf(fid,'Date,Q,Salt,Temp,TSS,DO,AMM,NIT,FRP,FRPADS,POC,DOC,PON,DON,POP,DOP,GRN,BGA,CRYPT,MDIAT,DINO,ZEROS,ONES\n');
    
    tdata.TotalNitrogen = tdata.TotalNitrogen * 1000/14;
    tdata.TotalPhosphorus = tdata.TotalPhosphorus * 1000/31;

    for k = 1:length(tdata.Dates)
        fprintf(fid,'%s,',datestr(tdata.Dates(k),'dd/mm/yyyy'));
        fprintf(fid,'%4.4f,',tdata.FlowVolume(k) * (1000/86400));
        fprintf(fid,'35,');%Salt
        fprintf(fid,'20,');%Temp
        fprintf(fid,'%4.4f,',tdata.TotalSuspendedSolids(k));%TSS
        fprintf(fid,'220,');%DO
        fprintf(fid,'%4.4f,',tdata.TotalNitrogen(k) * 0.1);%AMM
        fprintf(fid,'%4.4f,',tdata.TotalNitrogen(k) * 0.75);%NIT
        fprintf(fid,'%4.4f,',tdata.TotalPhosphorus(k) * 0.25);%FRP
        fprintf(fid,'%4.4f,',(tdata.TotalPhosphorus(k) * 0.25) * 0.1);%FRP-ADS
        fprintf(fid,'2.266978,');%POC
        fprintf(fid,'22.669784,');%DOC
        fprintf(fid,'%4.4f,',tdata.TotalNitrogen(k) * 0.1);%PON
        fprintf(fid,'%4.4f,',tdata.TotalNitrogen(k) * 0.05);%DON
        fprintf(fid,'%4.4f,',tdata.TotalPhosphorus(k) * 0.225);%POP
        fprintf(fid,'%4.4f,',tdata.TotalPhosphorus(k) * 0.5);%DOP
        fprintf(fid,'0,0,0,0,0,');%GRN,BGA,CRYPT,MDIAT,DINO
        fprintf(fid,'0,1\n');%zeros,ones
    end
end