clear; close all;

ICf='W:\csiem\Model\TFV\csiem_model_tfvaed_2.0\includes\ic\initical_condition_2D_Nov.csv';
outfile='.\benthic_ecology_csiem20\initical_condition_2D_Nov_2022.csv';
% dat = tfv_readnetcdf(infile,'time',1);
% timesteps = dat.Time;
% 
% t0=datenum(2013,3,21);
% 
% ind=find(abs(timesteps-t0)==min(abs(timesteps-t0)));


data = [];

fid = fopen(ICf,'rt');

sLine = fgetl(fid);

headers = regexp(sLine,',','split');
headers = regexprep(headers,'\s','');
EOF = 0;
inc = 1;
while ~EOF
    
    sLine = fgetl(fid);
    
    if sLine == -1
        EOF = 1;
    else
        dataline = regexp(sLine,',','split');
        
        for ii = 1:length(headers)
            
            
            switch upper(headers{ii})
                
                case 'ISOTIME'
                    try
                    data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy HH:MM');
                    catch
                       data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy');
                    end
                case 'DATE'
                    try
                    data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy HH:MM');
                    catch
                       data.Date(inc,1) = datenum(dataline{ii},...
                        'dd/mm/yyyy');
                    end
                otherwise
                    data.(headers{ii})(inc,1) = str2double(dataline{ii});
            end
        end
        inc = inc + 1;
    end
end

%%
vars={'WL','U','V','SAL','TEMP','TRACE_1','WQ_1','WQ_2','WQ_3','WQ_4','WQ_5','WQ_6','WQ_7','WQ_8','WQ_9','WQ_10','WQ_11','WQ_12','WQ_13','WQ_14','WQ_15','WQ_16','WQ_17','WQ_18','WQ_19','WQ_20','WQ_21'};

data.SAL=data.SAL-0.4;

fileID = fopen(outfile,'w');
fprintf(fileID,'%s\n','ID,WL,U,V,SAL,TEMP,TRACE_1,WQ_1,WQ_2,WQ_3,WQ_4,WQ_5,WQ_6,WQ_7,WQ_8,WQ_9,WQ_10,WQ_11,WQ_12,WQ_13,WQ_14,WQ_15,WQ_16,WQ_17,WQ_18,WQ_19,WQ_20,WQ_21');

for ii=1:length(data.ID)
    fprintf(fileID,'%6d',ii);
    for vv=1:length(vars)
        fprintf(fileID,',%6.4f',data.(vars{vv})(ii));
    end
    fprintf(fileID,'%s\n','');
end

fclose(fileID);
