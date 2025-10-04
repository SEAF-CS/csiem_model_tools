%%

clear; close all;

inDir='E:\anaconda\TUFLOW_FV_Python_Toolbox\my_atmos\';

hfig = figure('visible','on','position',[304         166        1271         812]);

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf,'paperposition',[0.635 6.35 20.32 10]);


for year=2000:2017

    str_s=[num2str(year-1),'1001_',num2str(year+1),'0105'];
    infile=[inDir,'BARRA_SUB_',str_s,'_UTC+8.0.nc'];
    disp(infile);

    finfo = ncinfo(infile);
    vars=finfo.Variables;

    time=double(ncread(infile,'local_time'))/24+datenum(1990,1,1);
    datearray=datenum(year-1,10:3:25,1);

    for vv=4:11
        varname=vars(vv).Name;
       % disp(varname);
        data=ncread(infile, varname, [35, 50, 1], [1, 1, Inf]);

        data2=squeeze(data(1,1,:));

        for t2=2:length(time)
            if time(t2)<=time(t2-1)
                disp(datestr(t2));
            end
        end

        for t3=1:length(data2)
            if isnan(data2(t3))
                disp(datestr(t3));
            end
        end


        plot(time,squeeze(data(1,1,:)));
        set(gca,'xlim',[datearray(1) datearray(end)],'XTick',datearray,'XTickLabel',datestr(datearray,'mm/yyyy'));
        %  set(gca,'ylim',[215 245]);
        varname2=strrep(varname,'_','-');
        ylabel(varname2);

        title([varname2,': ', num2str(year)]);

        img_name =['BARRA_',varname,' - ', num2str(year),'.png'];

        saveas(gcf,img_name);
    end

end


