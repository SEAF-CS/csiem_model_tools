clear; close all;

data1=load('ROMS_site_profiles_2001_2023.mat');
lid=[15 8 8];

for yy=2001:2023
    disp(yy);
    for i=1:3
        if yy==2001
            merged.(['site',num2str(i,'%1d')]).time=data1.outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).time;
            merged.(['site',num2str(i,'%1d')]).SAL =data1.outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).SAL(lid(i),:);
            merged.(['site',num2str(i,'%1d')]).TEMP=data1.outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).TEMP(lid(i),:);
        else
            tmptime=data1.outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).time;
            tmpsal=data1.outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).SAL(lid(i),:);
            tmptemp=data1.outdata.(['site',num2str(i,'%1d')]).(['year',num2str(yy,'%4d')]).TEMP(lid(i),:);

            t0=merged.(['site',num2str(i,'%1d')]).time(end);
            ind0=find(abs(tmptime-t0)==min(abs(tmptime-t0)));
            disp(datestr(tmptime(ind0+1)));
     
            l1=length(merged.(['site',num2str(i,'%1d')]).time);
            l2=length(tmptime(ind0+1:end));

            merged.(['site',num2str(i,'%1d')]).time(l1+1:l1+l2)=tmptime(ind0+1:end);
            merged.(['site',num2str(i,'%1d')]).SAL(l1+1:l1+l2) =tmpsal(ind0+1:end);
            merged.(['site',num2str(i,'%1d')]).TEMP(l1+1:l1+l2)=tmptemp(ind0+1:end);
        end

    end
end

save('ROMS_merged_2001_2023.mat','merged','-mat');