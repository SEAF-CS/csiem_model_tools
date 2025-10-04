
indx=[46 38 36 36 38 41];
indy=[48 47 39 32 28 25];

for i=1:length(indx)

    subplot(3,2,i);
    xx=indx(i);
    yy=indy(i);
sal01=SAL(xx,yy,2,:);sal01=squeeze(sal01(1,1,1,:));
sal02=SAL2(xx,yy,2,:);sal02=squeeze(sal02(1,1,1,:));


plot(time,movmean(sal01,24));
hold on;
plot(time, movmean(sal02,24));
hold on;

end