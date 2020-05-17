% 2016 07 07  Explore extracted clicks
% 2016 11 22  Calibrate click amplitude

% clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

trial = '20150426_am';
% trial = '20150426_pm';
% trial = '20150427_am';
throw = 1;

trial_throw = sprintf('%s_throw_%d',trial,throw);

% Path to extracted clicks
if isunix
    base_folder = '/Volumes/wjlee_apl_2/grampus_analysis/ANALYSIS';
else
    base_folder = 'F:\Dropbox\Z_wjlee\projects\grampus_suction_cup\ANALYSIS';
end

% Use script name for saving files
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_folder,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end
save_fname = sprintf('%s_%s_throw%d',...
                         script_name,trial,throw);


% Load data
m_folder = 'extract_clicks';
m_fname = sprintf('extract_clicks_%s_throw%d_*.mat',...
                  trial,throw);
% m_folder = 'extract_clicks';
% m_fname = sprintf('extract_clicks_%s_throw%d_*.mat',...
%                   trial,throw);
files = dir(fullfile(base_folder,m_folder,m_fname));
load(fullfile(base_folder,m_folder,files.name));


% Pool all extracted clicks together
click = cell2mat(click_extracted);
click_num = size(click,1);

click_locs = zeros(click_num,1);
click_num_each_file = zeros(length(click_extracted),1);

filenum = cell(length(detected_param),1);
fig_click_time = figure;
for iF=1:length(detected_param)
    click_num_each_file(iF) = length(detected_param{iF});
    if iF==1
        idx = 1:click_num_each_file(iF);
    else
        idx = sum(click_num_each_file(1:iF-1))+(1:click_num_each_file(iF));
    end
    click_locs(idx) = [detected_param{iF}.locs]+...
        (iF-1)*param.sig_pts_per_file;
    plot(idx,click_locs(idx)/param.fs,'.');
    hold on
    filenum{iF} = ['wav file ',num2str(iF)];
end
hold off
xlabel('Click number');
ylabel('Time (s)');
grid
tt = sprintf('%s, click time',trial_throw);
tt(tt=='_') = ' ';
title(tt)
ll = legend(filenum);
set(ll,'location','southeast','fontsize',12)
saveSameSize_100(fig_click_time,'file',...
    fullfile(save_path,[save_fname,'_click_time.png']),...
    'format','png');
saveas(fig_click_time,fullfile(save_path,[save_fname,'_click_time.fig']),'fig');


% Click features
SNR = nan(click_num,length(param.ch_wanted));
click_p2p_amp = nan(click_num,length(param.ch_wanted));
click_p2p_amp_norm = nan(click_num,length(param.ch_wanted));
click_max_ch = nan(click_num,1);
for iC=1:click_num
    click_curr = squeeze(click(iC,:,:))';
    click_p2p_amp(iC,:) = range(click_curr,1);
    [mm,click_max_ch(iC)] = max(range(click_curr,1));
    click_p2p_amp_norm(iC,:) = click_p2p_amp(iC,:)/mm;
    for iCH=1:length(param.ch_wanted)
        pt_len_fft =128;
        pt_len_overlap = round(pt_len_fft*0.9);
        [~,F,T,P] = spectrogram(click_curr(:,iCH),...
            pt_len_fft,pt_len_overlap,pt_len_fft,param.fs);
        P_time = sum(P,1);
        [~,P_max_idx] = max(P_time);
        if P_max_idx-5<1 || P_max_idx+5>length(P_time)
            SNR(iC,iCH) = 0;
        else   % ad-hoc SNR based on band-average
            SNR(iC,iCH) = 10*log10(sum(P_time(P_max_idx+(-5:5)))/sum(P_time(1:11)));
        end
    end
end

SNR_good = SNR>5;
click_good_idx = sum(SNR_good,2)==6;

click_ch2_amp = click_p2p_amp(:,2);
ici = diff(click_locs)/param.fs*1e3;  % ICI [ms]
regc = [ici>5;0];  % regular click
buzz = [ici<5;0];  % buzz
cseq = 1:click_num;  % sequence number of good clicks

click_p2p_amp_dB = 20*log10(click_p2p_amp);


% Apply suction cup phone calibration
CAL = load(fullfile(base_folder,'suction_cup_cal_results.mat'));
gain_relative = CAL.p2p_dB_gainComp_mean(2:8)-CAL.p2p_dB_gainComp_mean(1);
ch_seq_on_head = param.chseq(:,2);
gain_ch_seq_on_head = gain_relative(ch_seq_on_head);
% gain_ch_seq_on_head = gain_ch_seq_on_head([3,2,1,4,5,6]);

click_p2p_amp_dB_cal = click_p2p_amp_dB -...
    repmat(gain_ch_seq_on_head(param.ch_wanted),size(click_p2p_amp_dB,1),1);
click_p2p_amp_dB_cal_norm = click_p2p_amp_dB_cal-...
    repmat(click_p2p_amp_dB_cal(:,2),1,size(click_p2p_amp_dB_cal,2));




cgrey = [1 1 1]*150/255;

% click p2p amp, spread plot
fig_p2p_spread = figure('position',[160 90 1500 850]);

subplot(3,1,1); % 2nd channel on melon
h_all = plot(click_locs/param.fs,click_p2p_amp_dB(:,2),...  % all clicks
             'o','markersize',2,'color',cgrey,'markerfacecolor',cgrey);
hold on
h_goodc = plot(click_locs(click_good_idx)/param.fs,...  % good clicks
               click_p2p_amp_dB(click_good_idx,2),...
               'o','markersize',2,'color','b','markerfacecolor','b');
legend([h_all,h_goodc],'all','good SNR','location','southeast');
ylabel('Raw amplitude (dB)');
tt = sprintf('%s, raw p2p amp at ch2',trial_throw);
tt(tt=='_') = ' ';
title(tt)

subplot(3,1,2:3);  % all channels
corder=get(gca,'colororder');
plot(click_locs,click_p2p_amp_dB_cal_norm,...  % all clicks
     '.','markersize',5,'color',cgrey);
%plot(click_locs,20*log10(click_p2p_amp_norm),...  % all clicks
%     '.','markersize',4);
for iCH=1:6  % good clicks
    hold on
    h_ch(iCH) = plot(click_locs(click_good_idx),...
                click_p2p_amp_dB_cal_norm(click_good_idx,iCH),...
                'o','markersize',2,'color',corder(iCH,:),...
                'markerfacecolor',corder(iCH,:));
end
legend(h_ch,{'ch1','ch2','ch3','ch4','ch5','ch6'},...
       'location','southeast');
grid
yy = ylim;
ylim([yy(1) 2])
tt = sprintf('%s, normalized p2p amp',trial_throw);
tt(tt=='_') = ' ';
title(tt)
xlabel('Time (s)');
ylabel('Normalized amplitude (dB)');

saveSameSize_100(fig_p2p_spread,'file',fullfile(save_path,[save_fname,'_p2p_spread.png']),...  
                 'format','png');
saveas(fig_p2p_spread,fullfile(save_path,[save_fname,'_p2p_spread.fig']),'fig');



% ======= ALL CLICKS =========================================
% click p2p amplitude, all clicks
fig_p2p_all = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_p2p_amp_dB_cal(:,2),...
                click_p2p_amp_dB_cal(:,iCH),...
                10,1:length(click_ch2_amp),'filled');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Raw p2p at each ch');
    xlabel('Raw p2p at ch2');
    grid
    box
end
tt = sprintf('%s, p2p amp, all clicks',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)

saveSameSize_100(fig_p2p_all,'file',fullfile(save_path,[save_fname,'_p2p_all.png']),...  
                 'format','png');
saveas(fig_p2p_all,fullfile(save_path,[save_fname,'_p2p_all.fig']),'fig');


% Color-coded ICI plot, all clicks
fig_ici_all = figure;
ss = scatter(click_locs(1:end-1)/param.fs,...
            ici,15,1:length(ici),'filled');
colormap(jet)
grid
box
xlabel('Time (s)');
ylabel('ICI (ms)');
set(gca,'yscale','log')
tt = sprintf('%s, ICI, all clicks',trial_throw);
tt(tt=='_') = ' ';
title(tt)

saveSameSize_100(fig_ici_all,'file',fullfile(save_path,[save_fname,'_ici_all.png']),...  
                 'format','png');
saveas(fig_ici_all,fullfile(save_path,[save_fname,'_ici_all.fig']),'fig');

% % normalized click p2p amp, all clicks
% fig_p2p_norm_all = figure('position',[160 90 1500 850]);
% for iCH=1:6
%     subplot(2,3,iCH);
%     ss = scatter(click_p2p_amp_dB_cal(:,2),...
%                 click_p2p_amp_dB_cal_norm(:,iCH),...
%                 10,1:length(click_ch2_amp),'filled');
%     colormap(jet)
%     title(['ch',num2str(iCH)]);
%     ylabel('Normalized p2p at each ch');
%     xlabel('Raw P2P at ch2');
%     grid
%     box
% end
% tt = sprintf('%s, normalized p2p amp, all clicks',trial_throw);
% tt(tt=='_') = ' ';
% suptitle(tt)
% 
% saveSameSize_100(fig_p2p_norm_all,'file',fullfile(save_path,[save_fname,'_p2p_norm_all.png']),...  
%                  'format','png');



% ======= GOOD SNR CLICKS ONLY =========================================
if 0
% click p2p amplitude, good SNR only
fig_p2p_goodc = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    plot(click_p2p_amp_dB_cal(:,2),click_p2p_amp_dB_cal(:,iCH),...
         'o','markersize',4,'color',cgrey);
    hold on
    ss = scatter(click_p2p_amp_dB_cal(click_good_idx,2),...
                click_p2p_amp_dB_cal(click_good_idx,iCH),...
                10,1:sum(click_good_idx),'filled');
%     set(gca,'xscale','log','yscale','log');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Raw p2p at each ch');
    xlabel('Raw p2p at ch2');
    grid
    box
end
tt = sprintf('%s, p2p amp, good SNR only',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)

saveSameSize_100(fig_p2p_goodc,'file',fullfile(save_path,[save_fname,'_p2p_goodc.png']),...  
                 'format','png');

% normalized click p2p amp, good SNR only
fig_p2p_norm_goodc = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    plot(click_p2p_amp_dB_cal(:,2),...
        click_p2p_amp_dB_cal_norm(:,iCH),...
         'o','markersize',4,'color',cgrey);
    hold on
    ss = scatter(click_p2p_amp_dB_cal(click_good_idx,2),...
                click_p2p_amp_dB_cal_norm(click_good_idx,iCH),...
                10,1:sum(click_good_idx),'filled');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Normalized p2p at each ch');
    xlabel('Raw P2P at ch2');
    grid
    box
end
tt = sprintf('%s, normalized p2p amp, good SNR only',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)

saveSameSize_100(fig_p2p_norm_goodc,'file',fullfile(save_path,[save_fname,'_p2p_norm_goodc.png']),...  
                 'format','png');

% Color-coded ICI plot, good SNR only
fig_ici_goodc = figure;
plot(click_locs(1:end-1)/param.fs,ici,'o','markersize',4,...
     'color',cgrey);
hold on
ss = scatter(click_locs(click_good_idx(1:end-1))/param.fs,...
            ici(click_good_idx(1:end-1)),...
            15,1:sum(click_good_idx(1:end-1)),'filled');
colormap(jet)
grid
box
xlabel('Time (s)');
ylabel('ICI (ms)');
set(gca,'yscale','log')
tt = sprintf('%s, ICI, good SNR only',trial_throw);
tt(tt=='_') = ' ';
title(tt)

saveSameSize_100(fig_ici_goodc,'file',fullfile(save_path,[save_fname,'_ici_goodc.png']),...  
                 'format','png');

             
end


             
