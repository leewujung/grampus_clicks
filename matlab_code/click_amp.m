% 2016 07 07  Explore extracted clicks
% 2016 11 22  Calibrate click amplitude

% clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

trial = '20150426_am';
%trial = '20150426_pm';
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

%--------------------------
param.mat_folder = m_folder;
param.mat_filename = m_fname;
%--------------------------


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
set(gca,'fontsize',16);
tt = sprintf('%s, click time',trial_throw);
tt(tt=='_') = ' ';
title(tt)
ll = legend(filenum);
set(ll,'location','southeast','fontsize',16)
saveSameSize_100(fig_click_time,'file',...
    fullfile(save_path,[save_fname,'_click_time.png']),...
    'format','png');
saveas(fig_click_time,fullfile(save_path,[save_fname,'_click_time.fig']),'fig');

%--------------------------
data.filenum = filenum;
data.click_num = click_num;
data.click_num_each_file = click_num_each_file;
data.click = click;
data.click_locs = click_locs;
%--------------------------


% Click features
SNR = nan(click_num,length(param.ch_wanted));
click_p2p_amp = nan(click_num,length(param.ch_wanted));
click_max_ch = nan(click_num,1);
for iC=1:click_num
    click_curr = squeeze(click(iC,:,:))';
    click_p2p_amp(iC,:) = range(click_curr,1);
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

%--------------------------
data.click_p2p_amp = click_p2p_amp;
data.SNR = SNR;
%--------------------------


% Apply suction cup phone calibration
TC4013_sens = -211;
preamp_gain = 24;
CAL = load(fullfile(base_folder,'suction_cup_cal_results.mat'));
gain_relative = CAL.p2p_dB_gainComp_mean(2:8)-CAL.p2p_dB_gainComp_mean(1);
ch_seq_on_head = param.chseq(:,2);
gain_ch_seq_on_head = gain_relative(ch_seq_on_head);

CAL.gain_relative = gain_relative;
CAL.gain_ch_seq_on_head = gain_ch_seq_on_head;

click_p2p_amp_dB_cal = click_p2p_amp_dB -TC4013_sens -preamp_gain -...
    repmat(gain_ch_seq_on_head(param.ch_wanted),size(click_p2p_amp_dB,1),1);
click_p2p_amp_dB_cal_norm = click_p2p_amp_dB_cal-...
    repmat(click_p2p_amp_dB_cal(:,2),1,size(click_p2p_amp_dB_cal,2));

%--------------------------
param.TC4013_sens = TC4013_sens;
param.preamp_gain = preamp_gain;
param.CAL = CAL;
data.click_p2p_amp_dB_cal = click_p2p_amp_dB_cal;
%--------------------------

% Save click p2p data
save(fullfile(save_path,[save_fname,'.mat']),'data','param');



