% 2015 05 16  Quick look at channel differences


% Path to acoustic data
sound_file_want = 61;  % 20150427 am trial 1, first throw
suptitle_text = '20150426 am, trial 1, throw 1';
% sound_file_want = 52;  % 20150427 am trial 1, first throw
% suptitle_text = '20150427 am, trial 1, throw 1';
% sound_file_want = 65;  % 20150427 am trial 2, second throw
% suptitle_text = '20150427 am, trial 1, throw 2';

file_post = '_filt_mic_data_detect.mat';
master_folder = 'E:\Grampus_data\20150426\trial1_am\master_matfiles_filt';
master_file_pre = 'master_20150426_102505_';

master_fname = [master_file_pre,sprintf('%04d',sound_file_want),file_post];
load([master_folder,filesep,master_fname]);

% Filter channel 2
filter_folder = 'C:\Users\boto\Dropbox\0_grampus_suction_cup\ANALYSIS\20150516';
lpf_fname = 'lpf_150-250kHz_equiripple.mat';
load([filter_folder,filesep,lpf_fname]);

sig(:,2) = filtfilt(lpf_low150_num,1,sig(:,2));

% Go through each file to store clicks
ex_pts = -300:300;
ex_len = length(ex_pts);

click_num = length(call);
ch_num = size(sig,2);

click_ex_all = cell(click_num,1);
click_ex_fft_all = cell(click_num,1);
click_p2p_amp = zeros(click_num,ch_num);
for iC=1:click_num
    click_current = sig(call(iC).locs+ex_pts,:);
    click_p2p_amp(iC,:) = range(click_current,1);
    click_ex_all{iC} = click_current;
    click_ex_fft_all{iC} = fft(click_current);
end

click_p2p_amp_norm = click_p2p_amp./repmat(click_p2p_amp(:,5),1,8);
freq_click = linspace(0,fs,length(ex_pts));

click_ch6_amp = click_p2p_amp(:,5);
ici = diff([call(:).locs])/fs*1e3;


% Plot
% Click amp raw
figure;
subplot(411)
plot(20*log10(click_ch6_amp))
ylabel('Click amplitude (dB)');
title('Click amplitude of loudest channel')
xlim([0 click_num])

subplot(4,1,2:3)
plot(20*log10(click_p2p_amp(:,1:7)))
% ylim([-40 5])
ylabel('Click amplitude (dB)');
title('Click amplitude')
xlim([0 click_num])

subplot(4,1,4)
plot(ici)
set(gca,'yscale','log')
ylabel('Inter-click interval (us)');
title('Inter-click interval')
xlim([0 click_num])
ylim([1e0 1e3])
set(gca,'ytick',[1e0 1e1 1e2 1e3]);
xlabel('Click number');

suptitle(suptitle_text);

% Click amp normalized
figure;
subplot(411)
plot(20*log10(click_ch6_amp))
ylabel('Click amplitude (dB)');
title('Click amplitude of loudest channel')
xlim([0 click_num])

subplot(4,1,2:3)
plot(20*log10(click_p2p_amp_norm(:,1:7)))
ylim([-40 5])
ylabel('Normalized click amplitude (dB)');
title('Click amplitude, normalized to loudest channel')
xlim([0 click_num])

subplot(4,1,4)
plot(ici)
set(gca,'yscale','log')
ylabel('Inter-click interval (us)');
title('Inter-click interval')
xlim([0 click_num])
ylim([1e0 1e3])
set(gca,'ytick',[1e0 1e1 1e2 1e3]);
xlabel('Click number');

suptitle(suptitle_text);


figure;
for iCH=1:7
    subplot(2,4,iCH);
%     plot(click_ch6_amp,click_p2p_amp_norm(:,iCH),'b.');
    plot(20*log10(click_ch6_amp),20*log10(click_p2p_amp_norm(:,iCH)),'b.');
    xlabel('Raw click amp (dB)');
    ylabel('Normalized click amp (dB)');
    title(['Channel ',num2str(iCH)]);
end
suptitle(suptitle_text);


% Suction cup position sequence
cup_seq = [5,6,7,1,4,3,2];  % from tip of mouth, 20150426 am trial 1 throw 1
% cup_seq = [6,5,7,4,1,3,2];  % from tip of mouth, 20150427 am trial 1 throw 1&2
click_p2p_amp_cup_seq = click_p2p_amp(:,cup_seq);
click_p2p_amp_norm_cup_seq = click_p2p_amp_norm(:,cup_seq);

% Raw click amplitude
figure;
subplot(3,1,1:2)
imagesc(20*log10(click_p2p_amp_cup_seq)');
axis xy
xlim([0 click_num])
ylabel('Cup sequence on head');
title('Click amplitude');
colormap(flipud(brewermap([],'RdYlBu')))

subplot(313)
plot(20*log10(click_ch6_amp));
xlim([0 click_num])
ylabel('Click amplitude (dB)');
title('Click amplitude of loudest channel');
xlabel('Click number');

suptitle(suptitle_text);

% Click amplitude normalized
figure;
subplot(3,1,1:2)
imagesc(20*log10(click_p2p_amp_norm_cup_seq)');
axis xy
xlim([0 click_num])
ylabel('Cup sequence on head');
title('Click amplitude, normalized to loudest channel');
colormap(flipud(brewermap([],'RdYlBu')))

subplot(313)
plot(20*log10(click_ch6_amp));
xlim([0 click_num])
ylabel('Click amplitude (dB)');
title('Click amplitude of loudest channel');
xlabel('Click number');

suptitle(suptitle_text);


