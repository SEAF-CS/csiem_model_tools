
%load('E:\AED Dropbox\AED_Cockburn_db\CSIEM\Data\data-warehouse\mat\agency\csiem_IMOS_public.mat')

sites=fieldnames(csiem);

for ss=1:length(sites)
    disp(sites{ss});
    tmpsite=csiem.(sites{ss});

    vars=fieldnames(csiem.(sites{ss}));

    for vv=1:length(vars)
        tmpvar=csiem.(sites{ss}).(vars{vv});
        csiem_out.(sites{ss}).(vars{vv})=csiem.(sites{ss}).(vars{vv});

        if length(tmpvar.Data)>10000
            tmpdate=tmpvar.Date;

          %  tinterval=tmpdate(2:end)-tmpdate(1:end-1);


            t1=ceil(tmpdate(1));
            t2=floor(tmpdate(end));

            newdate=t1:1/24/t2;
            newdata=interp1(tmpdate,tmpvar.Data,newdate);
            newdataraw=interp1(tmpdate,tmpvar.Data_Raw,newdate);
            newdepth=interp1(tmpdate,tmpvar.Depth,newdate);
     %       newdeptho=interp1(tmpdate,tmpvar.oDepth,newdate);

            csiem_out.(sites{ss}).(vars{vv}).Date=newdate;
            csiem_out.(sites{ss}).(vars{vv}).Data=newdata;
            csiem_out.(sites{ss}).(vars{vv}).Data_Raw=newdataraw;
            csiem_out.(sites{ss}).(vars{vv}).Depth=newdepth;
       %     csiem_out.(sites{ss}).(vars{vv}).oDepth=newdeptho;

        end
    end
end






