clear; close;

infile='WWM_SWAN_CONV_Cgrid_2011.nc';

t=ncread(infile,'time');

for i=1:length(t)-1
    if t(i)>=t(i+1)
        disp(i);
    end
end

