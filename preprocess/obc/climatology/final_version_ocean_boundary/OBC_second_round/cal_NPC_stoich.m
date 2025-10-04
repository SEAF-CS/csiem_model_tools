%% estimate DOC:POC ratio from combination of field observations
clear; close all;

% POC at CS Region
POC=0.175/12*1000;  % mg/L
TN =0.125/14*1000;  % mg/L
TP =0.015/31*1000;  % mg/L
AMM=0.002/14*1000;  % mg/L
NIT=0.003/14*1000;  % mg/L
FRP=0.004/31*1000;  % mg/L -> mmol/m3

NPratio=TN/TP;
ON=(TN-AMM-NIT);
PON=POC*16/106;
DON=ON-PON;
DONPONratio=DON/PON;

OP=TP-FRP;
POP=POC*1/106;
DOP=OP-POP;
DOPPOPratio=DOP/POP;
