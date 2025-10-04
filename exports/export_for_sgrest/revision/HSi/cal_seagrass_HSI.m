clear; close all;

hsi_functions_posidonia_sinuosa;

sitenames={'KS1','KS2','KS3','KS4','KS5','R6','OA7','OA8','Collection'};

for s=1 %:length(sitenames)
     disp(sitenames{s});
     infile=['extracted_2023_combined_step2_',sitenames{s},'.mat'];
     data=load(infile);

     sal=mean(data.data2csv.SAL);
     HSI.(sitenames{s}).sal=interp1(sal_function(:,1), sal_function(:,2), sal);

     temp=mean(data.data2csv.TEMP);
     HSI.(sitenames{s}).temp=interp1(sal_function(:,1), sal_function(:,2), temp);

     lightper=mean(data.data2csv.LIGHTperc)*100;
     HSI.(sitenames{s}).lightper=interp1(light_function(:,1), light_function(:,2), lightper);

     vt=max(data.data2csv.VT);
     HSI.(sitenames{s}).vt=interp1(vel_function(:,1), vel_function(:,2), vt);

     P=prctile(data.data2csv.ORBITAL,99);
     HSI.(sitenames{s}).wave=interp1(wave_function(:,1), wave_function(:,2), P);



%      sal=output.(sitenames{s}).SAL.bottom;
%      temp=output.(sitenames{s}).TEMP.bottom;
% 
%      extc0=output.(sitenames{s}).WQ_DIAG_TOT_EXTC.profile;
%      extc=mean(extc0,1);
% 
%      vx=output.(sitenames{s}).V_x.bottom;
%      vy=output.(sitenames{s}).V_y.bottom;
% 
%      vt=sqrt(vx.^2+vy.^2);

end
