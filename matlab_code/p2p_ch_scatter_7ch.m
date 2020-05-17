% 2016 11 26  Click p2p amplitude distribution across all channels

clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

% trial = '20150426_am';
trial = '20150426_pm';
% ?trial = '20150427_am';
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
m_fname = sprintf('%s_%s_throw%d.mat',...
                  m_folder,trial,throw);
load(fullfile(base_folder,m_folder,m_fname));


% Plot p2p amplitude scatter plot
% click p2p amplitude, all clicks
fig_p2p_all = figure('position',[160 90 1500 850]);
for iCH=[1,3:7]
    if iCH==1
        subplot(2,3,iCH);
    else
        subplot(2,3,iCH-1);
    end
    plot([0 250],[0 250],'-','linewidth',2,'color',190/255*[1 1 1]);
    hold on
    ss = scatter(data.click_p2p_amp_dB_cal(:,2),...
                data.click_p2p_amp_dB_cal(:,iCH),...
                10,1:size(data.click_p2p_amp,1),'filled');
    colormap(jet)
    title(['CH',num2str(iCH)]);
    ylabel(sprintf('CH%d p2p (dB)',iCH));
    xlabel('CH2 p2p (dB)');
    axis equal
    axis([140 210 130 200])
    grid
    box on
    set(gca,'fontsize',12,'xtick',130:20:210,'ytick',130:20:210);
end
tt = sprintf('%s, p2p amp, all clicks',trial_throw);
suptitle(regexprep(tt,'_',' '))

saveSameSize_100(fig_p2p_all,'file',...
    fullfile(save_path,[save_fname,'_p2p_all.png']),...
    'format','png');
saveas(fig_p2p_all,...
    fullfile(save_path,[save_fname,'_p2p_all.fig']),'fig');

