% 2016 07 07  Explore extracted clicks

clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

%trial = '20150426_am';
%trial = '20150426_pm';
trial = '20150427_am';
throw = 4;

trial_throw = sprintf('%s_throw_%d',trial,throw);

% Path to extracted clicks
if isunix
    base_folder = '~/Dropbox/Z_wjlee/grampus_suction_cup/ANALYSIS';
else
    base_folder = 'C:\Users\Wu-Jung Lee\Dropbox\Z_wjlee\grampus_suction_cup\ANALYSIS';
end

% Use script name for saving files
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_folder,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end
save_fname_pre = sprintf('%s_%s_throw%d',...
                         script_name,trial,throw);


% Load data
m_folder = 'extract_clicks';
m_fname = sprintf('extract_clicks_%s_throw%d_*.mat',...
                  trial,throw);
files = dir(fullfile(base_folder,m_folder,m_fname));
load(fullfile(base_folder,m_folder,files.name));


% Pool all extracted clicks together
click = cell2mat(click_extracted);
click_num = size(click,1);

click_locs = zeros(click_num,1);
click_num_each_file = zeros(length(click_extracted),1);

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
end
hold off
xlabel('Click number');
ylabel('Time (s)');
grid
tt = sprintf('%s, click time',trial_throw);
tt(tt=='_') = ' ';
title(tt)
save_fname = sprintf('%s_click_time',save_fname_pre);
saveSameSize_100(fig_click_time,'file',fullfile(save_path,save_fname),...  
                 'format','png');


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
        else
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


cgrey = [1 1 1]*150/255;

% click p2p amp, spread plot
fig_p2p_spread = figure('position',[160 90 1500 850]);

subplot(3,1,1); % 2nd channel on melon
h_all = plot(click_locs/param.fs,20*log10(click_ch2_amp),...  % all clicks
             'o','markersize',2,'color',cgrey,'markerfacecolor',cgrey);
hold on
h_goodc = plot(click_locs(click_good_idx)/param.fs,...  % good clicks
               20*log10(click_ch2_amp(click_good_idx,:)),...
               'o','markersize',2,'color','b','markerfacecolor','b');
legend([h_all,h_goodc],'all','good SNR','location','southeast');
ylabel('Raw amplitude (dB)');
tt = sprintf('%s, raw p2p amp at ch2',trial_throw);
tt(tt=='_') = ' ';
title(tt)

subplot(3,1,2:3);  % all channels
corder=get(gca,'colororder');
plot(click_locs,20*log10(click_p2p_amp_norm),...  % all clicks
     '.','markersize',5,'color',cgrey);
%plot(click_locs,20*log10(click_p2p_amp_norm),...  % all clicks
%     '.','markersize',4);
for iCH=1:6  % good clicks
    hold on
    h_ch(iCH) = plot(click_locs(click_good_idx),...
                20*log10(click_p2p_amp_norm(click_good_idx,iCH)),...
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

save_fname = sprintf('%s_p2p_spread',save_fname_pre);
saveSameSize_100(fig_p2p_spread,'file',fullfile(save_path,save_fname),...  
                 'format','png');


% click p2p amplitude, good SNR only
fig_p2p_goodc = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    plot(click_ch2_amp,click_p2p_amp(:,iCH),...
         'o','markersize',4,'color',cgrey);
    hold on
    ss = scatter(click_ch2_amp(click_good_idx),...
                click_p2p_amp(click_good_idx,iCH),...
                10,1:sum(click_good_idx),'filled');
    set(gca,'xscale','log','yscale','log');
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
save_fname = sprintf('%s_p2p_goodc',save_fname_pre);
saveSameSize_100(fig_p2p_goodc,'file',fullfile(save_path,save_fname),...  
                 'format','png');


% click p2p amplitude, all clicks
fig_p2p_all = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_ch2_amp,...
                click_p2p_amp(:,iCH),...
                10,1:length(click_ch2_amp),'filled');
    set(gca,'xscale','log','yscale','log');
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
save_fname = sprintf('%s_p2p_all',save_fname_pre);
saveSameSize_100(fig_p2p_all,'file',fullfile(save_path,save_fname),...  
                 'format','png');


% normalized click p2p amp, good SNR only
fig_p2p_norm_goodc = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_ch2_amp(click_good_idx),...
                click_p2p_amp_norm(click_good_idx,iCH),...
                10,1:sum(click_good_idx),'filled');
    set(gca,'xscale','log','yscale','log');
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
save_fname = sprintf('%s_p2p_norm_goodc',save_fname_pre);
saveSameSize_100(fig_p2p_norm_goodc,'file',fullfile(save_path,save_fname),...  
                 'format','png');


% normalized click p2p amp, all clicks
fig_p2p_norm_all = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_ch2_amp,...
                click_p2p_amp_norm(:,iCH),...
                10,1:length(click_ch2_amp),'filled');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Normalized p2p at each ch');
    xlabel('Raw P2P at ch2');
    grid
    box
end
tt = sprintf('%s, normalized p2p amp, all clicks',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)
save_fname = sprintf('%s_p2p_norm_all',save_fname_pre);
saveSameSize_100(fig_p2p_norm_all,'file',fullfile(save_path,save_fname),...  
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
save_fname = sprintf('%s_ici_goodc',save_fname_pre);
saveSameSize_100(fig_ici_goodc,'file',fullfile(save_path,save_fname),...  
                 'format','png');


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
save_fname = sprintf('%s_ici_all',save_fname_pre);
saveSameSize_100(fig_ici_all,'file',fullfile(save_path,save_fname),...  
                 'format','png');

if 0
%% ============ beta figures ================
% click p2p amp, good SNR only, click/buzz separated
fig_p2p_goodc_cb = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    ss_regc = scatter(click_ch2_amp(click_good_idx&regc),...
                click_p2p_amp(click_good_idx&regc,iCH),...
                10,cseq(click_good_idx&regc),'filled');
    set(ss_regc,'marker','^');
    hold on
    ss_buzz = scatter(click_ch2_amp(click_good_idx&buzz),...
                click_p2p_amp(click_good_idx&buzz,iCH),...
                10,cseq(click_good_idx&buzz),'filled');
    set(ss_buzz,'marker','o');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
    grid
    box
end
tt = sprintf('%s, p2p amp, good SNR only, click/buzz',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)
save_fname = sprintf('%s_p2p_norm_all',save_fname_pre);
saveSameSize_100(fig_p2p_goodc_cb,'file',fullfile(save_path,save_fname),...  
                 'format','png');


% ICI, click/buzz separated
fig_ici_bc = figure;
idx = click_good_idx&regc;
idx(end) = [];
hc = plot(find(idx),ici(idx),'.');
hold on
idx = click_good_idx&buzz;
idx(end) = [];
hb = plot(find(idx),ici(idx),'.');
legend([hc,hb],'click','buzz');
set(gca,'yscale','log');
title('ICI, click/buzz')
tt = sprintf('%s, ICI, click/buzz',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)
save_fname = sprintf('%s_ici_bc',save_fname_pre);
saveSameSize_100(fig_ici_bc,'file',fullfile(save_path,save_fname),...  
                 'format','png');

% click p2p amp, click/buzz separated symbols
fig_p2p_goodc_cb_sym = figure('position',[160 90 1500 850]);
for iCH=1:6
    subplot(2,3,iCH);
    idx = click_good_idx & regc;
    plot(click_ch2_amp(idx),...
        click_p2p_amp(idx,iCH),'.');
    hold on
    idx = click_good_idx & buzz;
    plot(click_ch2_amp(idx),...
        click_p2p_amp(idx,iCH),'.');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
    if iCH==1
        legend('click','buzz');
    end
    grid
    box
end
tt = sprintf('%s, p2p amp, good SNR only, click/buzz',trial_throw);
tt(tt=='_') = ' ';
suptitle(tt)
save_fname = sprintf('%s_p2p_goodc_cb_sym',save_fname_pre);
saveSameSize_100(fig_p2p_goodc_cb_sym,'file',fullfile(save_path,save_fname),...  
                 'format','png');
end
