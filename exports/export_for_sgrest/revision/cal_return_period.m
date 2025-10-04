returnT = [2;10;25;50;100]/12;
returnP = 1-(1./returnT);
parmhatP=gevfit(data2csv.ORBITAL);
w1 = gevinv(returnP,parmhatP(1),parmhatP(2),parmhatP(3));
returnpV = 1:10:100;
returnTp = 1-(1./returnpV);
figure();
returnLevel_P   = gevinv(returnTp,parmhatP(1),parmhatP(2),parmhatP(3));
plot(returnpV,returnLevel_P,'k',returnT,w1,'k*');hold on
ylim([150 500]);
title('Precipitation');
xlabel('Return period [years]');
ylabel('Return level [mm/mo]');
grid on