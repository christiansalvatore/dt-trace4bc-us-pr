tot_exc=xlsread('C:\Users\Matteo\Desktop\feature_test_harm.xlsx', 'Foglio1', 'B2:BJ85');
batch=tot_exc(1:end-1,1)';
dat=tot_exc(1:end-1,2:end)';
paziente_test_batch=tot_exc(end,1)';
paziente_test_dat=tot_exc(end,2:end)';
% mod=batch';
% mod=sort(mod);

mod=[];
[data_harmonized_1, stand_mean_1, var_pooled_1, gamma_star_1, delta_star_1, parametric_1] = combat(dat, batch, mod, 1);
[data_harmonized_2, stand_mean_2, var_pooled_2, gamma_star_2, delta_star_2, parametric_2] = combat(dat, batch, mod, 0);
figure

p_bayesdata_1=combat_single_subj(paziente_test_dat, stand_mean_1, var_pooled_1, gamma_star_1, delta_star_1, paziente_test_batch);
p_bayesdata_2=combat_single_subj(paziente_test_dat, stand_mean_2, var_pooled_2, gamma_star_2, delta_star_2, paziente_test_batch);

for i=1:size(dat,1)
    subplot(1,3,1)
    histogram(dat(i,batch==1),'FaceColor','r');
    hold on
    histogram(dat(i,batch==2),'FaceColor','b');
    plot(paziente_test_dat(i),5,'g*',...   
    'MarkerSize',10,...
    'MarkerEdgeColor','g',...
    'MarkerFaceColor','g');
    hold off
    subplot(1,3,2)
    histogram(data_harmonized_1(i,batch==1),'FaceColor','r');
    hold on
    histogram(data_harmonized_1(i,batch==2),'FaceColor','b');
    plot(p_bayesdata_1(i),5,'g*',...   
    'MarkerSize',10,...
    'MarkerEdgeColor','g',...
    'MarkerFaceColor','g');
    hold off
    subplot(1,3,3)
    histogram(data_harmonized_2(i,batch==1),'FaceColor','r');
    hold on
    histogram(data_harmonized_2(i,batch==2),'FaceColor','b');
    plot(p_bayesdata_2(i),5,'g*',...   
    'MarkerSize',10,...
    'MarkerEdgeColor','g',...
    'MarkerFaceColor','g');
    hold off
    pause
end
