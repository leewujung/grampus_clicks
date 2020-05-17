% 2016 07 07  Explore extracted clicks

% Path to extracted clicks
if isunix
    base_data_folder = '~/internal_2tb/grampus_data';
    file_post = 'mic_data.mat';
    switch trial
        case '20150426_am'
            m_folder = '/20150426/trial1_am/master_matfiles_filt';
            m_file_pre = 'master_20150426_102505';
        case '20150426_pm'
            m_folder = '/20150426/trial2_pm/master_matfiles_filt';
            m_file_pre = 'master_20150426_145631';
        case '20150427_am'
            m_folder = '/20150427/trial1_am/master_matfiles_filt';
            m_file_pre = 'master_20150427_103045';
    end
else
    base_data_folder = 'C:\Users\Wu-Jung Lee\Documents\grampus_data';
    file_post = 'mic_data.mat';
    switch trial
        case '20150426_am'
            m_folder = '\20150426\trial1_am\master_matfiles_filt';
            m_file_pre = 'master_20150426_102505';
        case '20150426_pm'
            m_folder = '\20150426\trial2_pm\master_matfiles_filt';
            m_file_pre = 'master_20150426_145631';
        case '20150427_am'
            m_folder = '\20150427\trial1_am\master_matfiles_filt';
            m_file_pre = 'master_20150427_103045';
    end
end

% Load data
m_fname = sprintf('%s_%04d_filt_%s',m_file_pre,file_want_idx,file_post);
ss = strsplit(m_fname,'.');
m_det_fname = [ss{1},'_detect.mat'];

load(fullfile(base_data_folder,m_folder,m_fname));
load(fullfile(base_data_folder,m_folder,m_det_fname));
sig_raw = sig;

% Filter channel 2
lpf_fname = 'lpf_150-250kHz_equiripple.mat';
load(fullfile(filter_folder,lpf_fname));
sig(:,2) = filtfilt(lpf_low150_num,1,sig(:,2));

% Re-arrange channel according to sequence on head
chseq = [4,7,6,5,1,2,3;
          1,2,3,4,5,6,7]';
chseq = sortrows(chseq,1);
sig_chseq = sig(:,chseq(:,2)');

% Go through each file to store clicks
ex_pts = -500:1000;
ex_len = length(ex_pts);

click_num = length(call);
ch_num = 6;

sig = sig(:,1:ch_num);
sig_chseq = sig_chseq(:,1:ch_num);

SNR = nan(click_num,ch_num);
click_ex = nan(click_num,ch_num,ex_len);
click_p2p_amp = nan(click_num,ch_num);
click_p2p_amp_norm = nan(click_num,ch_num);
click_max_ch = nan(click_num,1);
for iC=1:click_num
    if call(iC).locs+ex_pts(end)>length(sig_chseq)
        len_append = call(iC).locs+ex_pts(end)-length(sig_chseq);
        click_curr = [sig_chseq(call(iC).locs+ex_pts(1):end,:);...
            zeros(len_append,ch_num)];
    else
        click_curr = sig_chseq(call(iC).locs+ex_pts,:);
    end
    click_ex(iC,:,:) = click_curr';
    click_p2p_amp(iC,:) = range(click_curr,1);
    [mm,click_max_ch(iC)] = max(range(click_curr,1));
    click_p2p_amp_norm(iC,:) = click_p2p_amp(iC,:)/mm;
    for iCH=1:ch_num
        pt_len_fft =128;
        pt_len_overlap = round(pt_len_fft*0.9);
        [~,F,T,P] = spectrogram(click_curr(:,iCH),...
            pt_len_fft,pt_len_overlap,pt_len_fft,fs);
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

freq_click = linspace(0,fs,length(ex_pts));

click_ch2_amp = click_p2p_amp(:,2);
ici = diff([call(:).locs])/fs*1e3;
regc = [ici>5,0]';  % regular click
buzz = [ici<5,0]';  % buzz
cseq = 1:click_num;  % sequence number of good clicks

figure
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_ch2_amp(click_good_idx),...
                click_p2p_amp(click_good_idx,iCH),...
                25,1:sum(click_good_idx),'filled');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Raw P2P at each ch');
    xlabel('Raw P2P at ch2');
end


figure
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_ch2_amp,...
                click_p2p_amp(:,iCH),...
                25,1:length(click_good_idx),'filled');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Raw P2P at each ch');
    xlabel('Raw P2P at ch2');
end


figure
subplot(3,1,1);
plot(20*log10(max(click_p2p_amp(click_good_idx,:),[],2)));
subplot(3,1,2:3);
plot(20*log10(click_p2p_amp_norm(click_good_idx,:)));


figure
for iCH=1:6
    subplot(2,3,iCH);
    ss = scatter(click_ch2_amp(click_good_idx),...
                click_p2p_amp_norm(click_good_idx,iCH),...
                25,1:sum(click_good_idx),'filled');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
    title(['ch',num2str(iCH)]);
    ylabel('Normalized P2P');
    xlabel('Raw P2P at ch2');
end

figure
for iCH=1:6
    subplot(2,3,iCH);
    ss_regc = scatter(click_ch2_amp(click_good_idx&regc),...
                click_p2p_amp(click_good_idx&regc,iCH),...
                25,cseq(click_good_idx&regc),'filled');
    set(ss_regc,'marker','^');
    hold on
    ss_buzz = scatter(click_ch2_amp(click_good_idx&buzz),...
                click_p2p_amp(click_good_idx&buzz,iCH),...
                25,cseq(click_good_idx&buzz),'filled');
    set(ss_buzz,'marker','o');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
end


figure
ss = scatter(1:sum(click_good_idx)-1,...
            ici(click_good_idx(1:end-1)),...
            25,1:sum(click_good_idx)-1,'filled');
colormap(jet)


figure
idx = click_good_idx&regc;
idx(end) = [];
plot(find(idx),ici(idx),'.');
hold on
idx = click_good_idx&buzz;
idx(end) = [];
plot(find(idx),ici(idx),'+');


figure;
for iCH=1:6
    subplot(2,3,iCH);
    idx = click_good_idx & regc;
    plot(click_ch2_amp(idx),...
        click_p2p_amp(idx,iCH),'.');
    hold on
    idx = click_good_idx & buzz;
    plot(click_ch2_amp(idx),...
        click_p2p_amp(idx,iCH),'+');
    set(gca,'xscale','log','yscale','log');
    colormap(jet)
end

        
        
        
        
