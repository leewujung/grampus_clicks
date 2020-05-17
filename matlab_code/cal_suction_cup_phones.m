% 2016 11 21  Calibrate suction cup phones
clear
addpath('F:/Dropbox/0_CODE/MATLAB/saveSameSize');

save_path = 'F:\grampus_data\calibration_whit';
cal_path = 'F:\grampus_data\calibration_whit\suction_cup_proc';
cal_file_all = dir(fullfile(cal_path,'*.mat'));

fig = figure('units','normalized','outerposition',[0 0 1 1]);
p2p = nan(35,length(cal_file_all));
p2p_dB = nan(35,length(cal_file_all));
p2p_dB_gainComp = nan(35,length(cal_file_all));
for iH=1:length(cal_file_all)
    cal_file = cal_file_all(iH).name;
    load(fullfile(cal_path,cal_file));

    ss = strsplit(strtok(cal_file,'.'),'-');
    
    % Gain and suction cup name
    if iH==1 || iH==9
        gain = 30;
        h_name = [ss{1}(1),'-BK'];
    else
        gain = str2double(ss{end}(1:end-2));
        h_name = [ss{1}(1),'-',ss{2}];
    end
    h_name_all{iH} = h_name;
    gain_all(iH,:) = gain;

    % plot
    subplot(6,2,iH)
    hc = plot(click);
    xlim([0 512])
    ll = legend(hc(1),h_name);
    set(ll,'fontsize',12)
    
    % Click amplitude
    p2p_tmp = max(click,[],1);
    
    p2p(1:size(click,2),iH) = p2p_tmp;
    p2p_dB(1:size(click,2),iH) = 20*log10(p2p_tmp);
    p2p_dB_gainComp(1:size(click,2),iH) = 20*log10(p2p_tmp)-gain;
end

p2p_dB_mean = nanmean(p2p_dB,1);
p2p_dB_gainComp_mean = nanmean(p2p_dB_gainComp,1);

save(fullfile(save_path,'suction_cup_cal_results.mat'),...
    'p2p','p2p_dB','p2p_dB_gainComp',...
    'p2p_dB_mean','p2p_dB_gainComp_mean');

saveas(fig,fullfile(save_path,'all_click_trace.fig'),'fig');
saveSameSize_150(fig,'file',fullfile(save_path,'all_click_trace.png'),...  
                 'format','png');

