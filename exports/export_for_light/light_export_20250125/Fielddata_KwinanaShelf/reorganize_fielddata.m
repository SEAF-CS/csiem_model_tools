clear; close all;

load light_spetrum_KwinanaShelf_uW.mat;

fields=fieldnames(spectrum);

for ff=1:length(fields)
    data.(fields{ff}).Date=spectrum.(fields{ff}).Date;
    data.(fields{ff}).Data=spectrum.(fields{ff}).Data;
    data.(fields{ff}).Depth=spectrum.(fields{ff}).Depth;
end

save('light_spetrum_KwinanaShelf_uW_v6.mat','data','-mat','-v6');