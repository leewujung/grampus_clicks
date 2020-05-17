% 2016 07 02  Filter signals in selected files to enable detection

% Files to filter
trial = '20150426_am';
file_want_idx_all = [60:62,92];

% Load filters
% filter_folder = 'C:\Users\Wu-Jung Lee\Dropbox\Z_wjlee\grampus_suction_cup\ANALYSIS\';
filter_folder = '/Volumes/wjlee_apl_2/grampus_analysis/ANALYSIS';
lpf_fname = 'lpf_250-300kHz_equiripple.mat';
hpf_fname = 'hpf_0-5kHz_equiripple.mat';
load([filter_folder,filesep,lpf_fname]);
load([filter_folder,filesep,hpf_fname]);

% Path to acoustic data
% base_data_folder = 'C:\Users\Wu-Jung Lee\Documents\grampus_data';
base_data_folder = '/Volumes/wjlee_apl_2/grampus_data';
file_post = 'mic_data.mat';
switch trial
    case '20150426_am'
        master_folder = '/20150426/trial1_am/master_matfiles';
        master_file_pre = 'master_20150426_102505';
        slave_folder = '/20150426/trial1_am/slave_matfiles';
        slave_file_pre = 'slave_20150426_102455';
    case '20150426_pm'
        master_folder = '/20150426/trial2_pm/master_matfiles';
        master_file_pre = 'master_20150426_145631';
        slave_folder = '/20150426/trial2_pm/slave_matfiles';
        slave_file_pre = 'slave_20150426_145621';
    case '20150427_am'
        master_folder = '/20150427\trial1_am/master_matfiles';
        master_file_pre = 'master_20150427_103045';
        slave_folder = '/20150427/trial1_am/slave_matfiles';
        slave_file_pre = 'slave_20150427_103024';
end

master_filt_folder = [master_folder,'_filt'];
slave_filt_folder = [slave_folder,'_filt'];
if ~exist(fullfile(base_data_folder,master_filt_folder),'dir')
    mkdir(fullfile(base_data_folder,master_filt_folder));
end
if ~exist(fullfile(base_data_folder,slave_filt_folder),'dir')
    mkdir(fullfile(base_data_folder,slave_filt_folder));
end

% Loop through files
for iF=file_want_idx_all
    file_want_idx = iF;
    
    % Load original data
    master_fname = sprintf('%s_%04d_%s',master_file_pre,file_want_idx,file_post);
    master = load(fullfile(base_data_folder,master_folder,master_fname));
    slave_fname = sprintf('%s_%04d_%s',slave_file_pre,file_want_idx,file_post);
    slave = load(fullfile(base_data_folder,slave_folder,slave_fname));
    
    % Filtered file name
    master_filt_fname = sprintf('%s_%04d_filt_%s',master_file_pre,file_want_idx,file_post);
    slave_filt_fname = sprintf('%s_%04d_filt_%s',slave_file_pre,file_want_idx,file_post);
    
    % Filter data
    ch_num = size(master.sig,2);
    for iCH=1:ch_num
        disp(['Filtering channel ',num2str(iCH)]);
        tmp = filtfilt(hpf_num,1,master.sig(:,iCH));  % highpass
        master.sig(:,iCH) = filtfilt(lpf_num,1,tmp);  % lowpass
        tmp = filtfilt(hpf_num,1,slave.sig(:,iCH));  % highpass
        slave.sig(:,iCH) = filtfilt(lpf_num,1,tmp);  % lowpass
    end
    fs = master.fs;
    
    % Save filtered da
    sig = master.sig;
    save(fullfile(base_data_folder,master_filt_folder,master_filt_fname),'sig','fs');
    sig = slave.sig;
    save(fullfile(base_data_folder,slave_filt_folder,slave_filt_fname),'sig','fs');
    
end