% 2016/06/26  Modified from Spectrum_Calibration.m from Whit/Adam

% Calibration of 2 side by side receivers by plotting and comparing the
% spectral content of received clicks collected via the Array Beam Pattern DAQ setup.
% For the current coding, this script assumes that the calibrated receiver is on Ch1 and the
% uncalibrated receiver is on Ch2.

clear
addpath('C:\Users\Wu-Jung Lee\Dropbox\0_CODE\MATLAB\saveSameSize');

% Set data folder & recording parameters
data_folder = 'C:\Users\Wu-Jung Lee\Documents\grampus_data\calibration_adam\AllFiles';
data_file_num = 3;
switch data_file_num
    case 1
        data_file = 'First File';
    case 2
        data_file = 'Second File';
    case 3
        data_file = 'Third File';
end
trial_num = 5;
G1 = 0;     % gain at ch1
G2 = 24;    % gain at ch2
sens_ch1 = -207.1225218; % assumed to be flat from 0 to 150 kHz based on calibration
fs = 500e3;  % sampling freq [Hz]

% Set save folder
base_save_path = 'C:\Users\Wu-Jung Lee\Dropbox\Z_wjlee\grampus_suction_cup\ANALYSIS';
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_path,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% Load data
data = load([fullfile(data_folder,data_file,sprintf('Trial %d',trial_num)),'\Clicks']);
% data = load(uigetfile);
[n_ch,n_col] = size(data);  % channel number
n_rep = n_col/16;           % number of repetitions

t_data = (0:size(data,1)-1)/fs;

% Plot for inspection
figure
plot(t_data*1e6,data(:,1)-mean(data(:,1)))
hold on
plot(t_data*1e6,data(:,2)-mean(data(:,2)))
xlabel('Time (us)');
grid
legend('Ch-ref', 'Ch2-uncalib');
title('First ping');
save_fname = sprintf('%s_timeseries_f%02d_t%02d',script_name,data_file_num,trial_num);
saveSameSize_100(gcf,'file',fullfile(save_path,save_fname),...
    'format','png');
saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');

% Detect peak location and extract signal
env_ch1 = abs(hilbert(data(:,1)-mean(data(:,1))));
env_ch2 = abs(hilbert(data(:,2)-mean(data(:,2))));
[max_env_ch1,max_idx_ch1] = max(env_ch1);
[max_env_ch2,max_idx_ch2] = max(env_ch2);
extract_idx_ch1 = max_idx_ch1+[-22:52];
extract_idx_ch2 = max_idx_ch2+[-22:52];

sig_ch1 = data(extract_idx_ch1,1:16:end);
sig_ch2 = data(extract_idx_ch2,2:16:end);

sig_fft_ch1 = fft(sig_ch1);
sig_fft_ch2 = fft(sig_ch2);
sig_power_ch1 = abs(sig_fft_ch1).^2;
sig_power_ch2 = abs(sig_fft_ch2).^2;
sig_power_mean_ch1 = mean(abs(sig_fft_ch1).^2,2);
sig_power_mean_ch2 = mean(abs(sig_fft_ch2).^2,2);

freq_vec = linspace(0,fs/2,round((size(sig_fft_ch1,1)+1)/2));
spectrum_len = length(freq_vec);

figure;
subplot(211)
plot(freq_vec/1e3,10*log10(sig_power_ch1(1:spectrum_len,:)));
hold on
plot(freq_vec/1e3,10*log10(sig_power_mean_ch1(1:spectrum_len)),'k--','linewidth',1);
xlabel('Frequency (kHz)');
ylabel('dB (arbitrary scale)');
title('Ch1: reference signal');
ylim([-50 15])
grid

subplot(212)
plot(freq_vec/1e3,10*log10(sig_power_ch2(1:spectrum_len,:)));
hold on
hh = plot(freq_vec/1e3,10*log10(sig_power_mean_ch2(1:spectrum_len)),'k--','linewidth',1);
ll = legend(hh,'mean spectrum');
set(ll,'fontsize',10);
xlabel('Frequency (kHz)');
ylabel('dB (arbitrary scale)');
title('Ch2: uncalibrated mic');
ylim([-50 15])
grid
save_fname = sprintf('%s_allSpectrum_f%02d_t%02d',script_name,data_file_num,trial_num);
saveSameSize_100(gcf,'file',fullfile(save_path,save_fname),...
    'format','png');
saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');


figure;
plot(freq_vec/1e3,10*log10(sig_power_mean_ch1(1:spectrum_len)),'linewidth',2);
hold on
plot(freq_vec/1e3,10*log10(sig_power_mean_ch2(1:spectrum_len)),'linewidth',2);
plot(freq_vec/1e3,10*log10(sig_power_mean_ch2(1:spectrum_len))-...
    10*log10(sig_power_mean_ch1(1:spectrum_len)),'linewidth',2);
xlabel('Frequency (kHz)');
ylabel('dB (arbitrary scale)');
title('Mean received level comparison');
ylim([-50 30])
grid
% legend('Reference mic','Uncalibrtaed mic')
legend('Reference mic','Uncalibrtaed mic','Uncalib-Ref')
save_fname = sprintf('%s_meanSpectrum_f%02d_t%02d',script_name,data_file_num,trial_num);
saveSameSize_100(gcf,'file',fullfile(save_path,save_fname),...
    'format','png');
saveas(gcf,fullfile(save_path,[save_fname,'.fig']),'fig');


% Calibration results
spkr = 10*log10(sig_power_mean_ch1(1:spectrum_len))-G1-sens_ch1;
sens_ch2 = 10*log10(sig_power_mean_ch2(1:spectrum_len))-spkr-G2;

