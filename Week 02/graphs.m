function [auc] = graphs(alpha,metrics,metrics2)

plot(alpha,metrics2(1,:),'r',alpha,metrics2(2,:),'g',alpha,metrics2(3,:),'b');
title 'Precision Recall Fmeasure'
xlabel('Alpha')
ylabel('Value')
legend('Precision','Recall','Fmeasure')
figure,
plot(metrics2(2,:),metrics2(1,:))
title 'Precision Recall curve'
xlabel('Recall')
ylabel('Precision')
auc = areaundercurve(metrics2(2,:),metrics2(1,:))
figure,
plot((metrics(2,:)./(metrics(2,:)+metrics(4,:))),metrics(1,:)./(metrics(1,:)+metrics(3,:)))
title 'ROC curve'
xlabel('FP ratio')
ylabel('TP ratio')


end
% fm1 = metrics when fall
% and so on

% fFPR= fm1(2,:)./(fm1(2,:)+fm1(4,:));
% fTPR= fm1(1,:)./(fm1(1,:)+fm1(3,:));
% hFPR= hm1(2,:)./(hm1(2,:)+hm1(4,:));
% hTPR= hm1(1,:)./(hm1(1,:)+hm1(3,:));
% tFPR= trm1(2,:)./(trm1(2,:)+trm1(4,:));
% tTPR= trm1(1,:)./(trm1(1,:)+trm1(3,:));
% fauc = areaundercurve(fFPR,fTPR)
% hauc = areaundercurve(hFPR,hTPR)
% tauc = areaundercurve(tFPR,tTPR)
% 
% plot((fm1(2,:)./(fm1(2,:)+fm1(4,:))),fm1(1,:)./(fm1(1,:)+fm1(3,:)),'r',...
% (hm1(2,:)./(hm1(2,:)+hm1(4,:))),hm1(1,:)./(hm1(1,:)+hm1(3,:)),'g',...
% (trm1(2,:)./(trm1(2,:)+trm1(4,:))),trm1(1,:)./(trm1(1,:)+trm1(3,:)),'b');
% title 'ROC curves'
% xlabel('FP ratio')
% ylabel('TP ratio')
% legend(strcat('fall auc= ', num2str(fauc)),strcat('highway auc=',num2str(hauc)),strcat('traffic auc=',num2str(tauc)))
% 
% fauc = areaundercurve(fm2(2,:),fm2(1,:))
% hauc = areaundercurve(hm2(2,:),hm2(1,:))
% tauc = areaundercurve(trm2(2,:),trm2(1,:))
% 
% plot(fm2(2,:),fm2(1,:),'r',hm2(2,:),hm2(1,:),'g',trm2(2,:),trm2(1,:),'b');
% title 'PR curves'
% xlabel('Recall')
% ylabel('Precision')
% legend(strcat('fall auc= ', num2str(fauc)),strcat('highway auc=',num2str(hauc)),strcat('traffic auc=',num2str(tauc)))