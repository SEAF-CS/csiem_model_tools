%% cal total load

clear; close all;
WWTPs={'Alkimos','Beenyup','Subiaco','Point Peron','Woodman Point','East Rockingham'};

for w=1:length(WWTPs)
    data=tfv_readBCfile(['./Proc/', WWTPs{w},'_tfv.csv']);
    mf=mean(data.Q)/30;
    tmp=data.PON+data.DON+data.NIT+data.AMM;
    mn=mean(tmp(~isnan(tmp)));
    tmp=data.POP+data.DOP+data.FRP+data.FRPADS;
    mp=mean(tmp(~isnan(tmp)));

    outputTF(w)=mf*86400/1000;
    outputTN(w)=mf*mn*86400*365*14/1e9;
    outputTP(w)=mf*mp*86400*365*31/1e9;

end