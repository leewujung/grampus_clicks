% 2016 11 26  Click p2p amplitude distribution across all channels

clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

trial = '20150426_am';
% trial = '20150426_pm';
% ?trial = '20150427_am';
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
m_folder = 'click_amp_7ch';
m_fname = sprintf('%s_%s_throw%d.mat',...
                  m_folder,trial,throw);
load(fullfile(base_folder,m_folder,m_fname));


click_num = 412;
sig = squeeze(data.click(click_num,:,:))';
sig_scale = zeros(size(sig));
sig_scale(:,1) = sig(:,1);
sig_scale(:,2) = sig(:,2);
sig_scale(:,3) = sig(:,3)*2;
sig_scale(:,4) = sig(:,4)*25;
sig_scale(:,5) = sig(:,5)*25;
sig_scale(:,6) = sig(:,6)*5;
sig_scale(:,7) = sig(:,7)*5;

sig_fft = fft(sig);
sig_freq = linspace(0,param.fs,length(sig));

sig_t = (0:length(sig_scale)-1)/param.fs;

fig = figure;
plot(sig_t(101:900)*1e6,...
     sig_scale(101:900,:)+repmat((1:7)*1,800,1),...
     'k','linewidth',2);
tt = sprintf('%s, p2p amp, click %d',trial_throw,click_num);
title(regexprep(tt,'_',' '))
set(gca,'fontsize',16);
xlabel('Time (us)');
title(['Click #',num2str(click_num)]);

% saveSameSize_100(fig,'file',...
%     fullfile(save_path,[save_fname,'.png']),...
%     'format','png');
% saveas(fig,...
%     fullfile(save_path,[save_fname,'.fig']),'fig');

fig_fft = figure;
for iCH=1:7
    subplot(4,2,iCH);
    mm_log = 20*log10(abs(sig_fft(:,iCH)));
    plot(sig_freq/1e3,mm_log-max(mm_log),...
         'b','linewidth',2);
    axis([0 200 -40 0])
end
title(['Click #',num2str(click_num)]);



click_num = 523;
sig = squeeze(data.click(click_num,:,:))';
sig_scale = zeros(size(sig));
sig_scale(:,1) = sig(:,1);
sig_scale(:,2) = sig(:,2);
sig_scale(:,3) = sig(:,3)*2;
sig_scale(:,4) = sig(:,4)*5;
sig_scale(:,5) = sig(:,5)*5;
sig_scale(:,6) = sig(:,6)*1;
sig_scale(:,7) = sig(:,7)*1;

sig_fft = fft(sig);
sig_freq = linspace(0,param.fs,length(sig));

sig_t = (0:length(sig_scale)-1)/param.fs;

fig = figure;
plot(sig_t(101:900)*1e6,...
     sig_scale(101:900,:)+repmat((1:7)*0.1,800,1),...
     'k','linewidth',2);
tt = sprintf('%s, p2p amp, click %d',trial_throw,click_num);
title(regexprep(tt,'_',' '))
set(gca,'fontsize',16);
xlabel('Time (us)');
title(['Click #',num2str(click_num)]);

% saveSameSize_100(fig,'file',...
%     fullfile(save_path,[save_fname,'.png']),...
%     'format','png');
% saveas(fig,...
%     fullfile(save_path,[save_fname,'.fig']),'fig');

fig_fft = figure;
for iCH=1:7
    subplot(4,2,iCH);
    mm_log = 20*log10(abs(sig_fft(:,iCH)));
    plot(sig_freq/1e3,mm_log-max(mm_log),...
         'b','linewidth',2);
    axis([0 200 -40 0])
end
title(['Click #',num2str(click_num)]);


click_num = 27;
sig = squeeze(data.click(click_num,:,:))';
sig_scale = zeros(size(sig));
sig_scale(:,1) = sig(:,1);
sig_scale(:,2) = sig(:,2);
sig_scale(:,3) = sig(:,3)*20;
sig_scale(:,4) = sig(:,4)*50;
sig_scale(:,5) = sig(:,5)*50;
sig_scale(:,6) = sig(:,6)*10;
sig_scale(:,7) = sig(:,7)*10;

sig_fft = fft(sig);
sig_freq = linspace(0,param.fs,length(sig));

sig_t = (0:length(sig_scale)-1)/param.fs;

fig = figure;
plot(sig_t(101:900)*1e6,...
     sig_scale(101:900,:)+repmat((1:7)*1,800,1),...
     'k','linewidth',2);
tt = sprintf('%s, p2p amp, click %d',trial_throw,click_num);
title(regexprep(tt,'_',' '))
set(gca,'fontsize',16);
xlabel('Time (us)');
title(['Click #',num2str(click_num)]);

% saveSameSize_100(fig,'file',...
%     fullfile(save_path,[save_fname,'.png']),...
%     'format','png');
% saveas(fig,...
%     fullfile(save_path,[save_fname,'.fig']),'fig');

fig_fft = figure;
for iCH=1:7
    subplot(4,2,iCH);
    mm_log = 20*log10(abs(sig_fft(:,iCH)));
    plot(sig_freq/1e3,mm_log-max(mm_log),...
         'b','linewidth',2);
    axis([0 200 -40 0])
end
title(['Click #',num2str(click_num)]);





