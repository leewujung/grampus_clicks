% 2016 11 26  Click p2p amplitude distribution across all channels

clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

% trial = '20150426_am';
trial = '20150426_pm';
% trial = '20150427_am';
throw = 2;

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
m_folder = 'click_amp_7ch';
m_fname = sprintf('click_amp_7ch_%s_throw%d.mat',...
                  trial,throw);
load(fullfile(base_folder,m_folder,m_fname));


% Plot amplitude distr
fig_err = figure('position',[468   329   560   338]);
hh = errorbar(mean(data.click_p2p_amp_dB_cal),...
           std(data.click_p2p_amp_dB_cal),...
           'o','markersize',12,'linewidth',2);
tt = sprintf('%s, p2p amp, all clicks',trial_throw);
title(regexprep(tt,'_',' '));
set(gca,'fontsize',16,'xtick',1:7);
xlabel('Channel');
ylabel('SPL (dB re 1 {\mu}Pa)');
xlim([0 8]);
ylim([140 200]);
grid

saveSameSize_100(fig_err,'file',...
    fullfile(save_path,[save_fname,'_errstd.png']),...
    'format','png');
saveas(fig_err,fullfile(save_path,[save_fname,'_errstd.fig']),'fig');


