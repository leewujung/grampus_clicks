% 2015 05 16  Quick look at grampus suction cup and array data

% video_flash_time = 4;  % sec  % 20150426 am, trial1
% video_want_raw = '5:08';  % min:sec  % 20150426 am, trial 1, first throw
video_flash_time = 4;  % sec  % 20150426 pm, trial2
video_want_raw = '8:34';  % min:sec  % 20150426 pm, trial 2, first throw
% video_flash_time = 7;  % sec  % 20150427 am, trial1
% video_want_raw = '4:24';  % min:sec  % 20150427 am, trial 1, first throw
% video_want_raw = '5:29';  % min:sec  % 20150427 am, trial 2, second throw


video_want_dum = strsplit(video_want_raw,':');
video_want_sec = str2num(video_want_dum{1})*60+str2num(video_want_dum{2});

sound_file_cut = 5;  % sec for splitting sound file
sound_file_dum = ceil(video_want_sec/sound_file_cut);
sound_file_want = sound_file_dum-1;


% Load filters
filter_folder = 'C:\Users\Wu-Jung Lee\Dropbox\Z_wjlee\grampus_suction_cup\ANALYSIS\20150516';
lpf_fname = 'lpf_250-300kHz_equiripple.mat';
hpf_fname = 'hpf_0-5kHz_equiripple.mat';
load([filter_folder,filesep,lpf_fname]);
load([filter_folder,filesep,hpf_fname]);


% Path to acoustic data
base_folder = 'C:\Users\Wu-Jung Lee\Documents\grampus_data';
file_post = '_mic_data.mat';
% ========== 20150426 am trial1 ===========
% master_folder = '\20150426\trial1_am\master_matfiles';
% master_file_pre = 'master_20150426_102505_';
% slave_folder = '\20150426\trial1_am\slave_matfiles';
% slave_file_pre = 'slave_20150426_102455_';
master_folder = '\20150426\trial2_pm\master_matfiles';
master_file_pre = 'master_20150426_145631_';
slave_folder = '\20150426\trial2_pm\slave_matfiles';
slave_file_pre = 'slave_20150426_145621_';
% ========== 20150427 am trial1 ===========
% master_folder = '\20150427\trial1_am\master_matfiles';
% master_file_pre = 'master_20150427_103045_';
% slave_folder = '\20150427\trial1_am\slave_matfiles';
% slave_file_pre = 'slave_20150427_103024_';

master_filt_folder = [master_folder,'_filt'];
slave_filt_folder = [slave_folder,'_filt'];
if ~exist(master_filt_folder,'dir')
    mkdir(master_filt_folder);
end
if ~exist(slave_filt_folder,'dir')
    mkdir(slave_filt_folder);
end

% Load one channel to calculate recording length
master_fname = [master_file_pre,sprintf('%04d',sound_file_want),file_post];
master = load([master_folder,filesep,master_fname]);

sound_file_len_pt = size(master.sig,1);
fs = master.fs;
sound_file_len = sound_file_len_pt/fs;  % sec


% Re-estimate the closest audio file
sound_file_dum = ceil(video_want_sec/sound_file_len);
sound_file_want = sound_file_dum-1+1;

master_fname = [master_file_pre,sprintf('%04d',sound_file_want),file_post];
master = load([master_folder,filesep,master_fname]);
slave_fname = [slave_file_pre,sprintf('%04d',sound_file_want),file_post];
slave = load([slave_folder,filesep,slave_fname]);

master_filt_fname = [master_file_pre,sprintf('%04d',sound_file_want),'_filt',file_post];
slave_filt_fname = [slave_file_pre,sprintf('%04d',sound_file_want),'_filt',file_post];

time_stamp = (0:(size(master.sig,1)-1))/fs;

% Filter data
ch_num = size(master.sig,2);
for iCH=1:ch_num
    disp(['Filtering channel ',num2str(iCH)]);
    tmp = filtfilt(hpf_num,1,master.sig(:,iCH));  % highpass
    master.sig(:,iCH) = filtfilt(lpf_num,1,tmp);  % lowpass
    tmp = filtfilt(hpf_num,1,slave.sig(:,iCH));  % highpass
    slave.sig(:,iCH) = filtfilt(lpf_num,1,tmp);  % lowpass
end

% Save filtered da
sig = master.sig;
save([master_filt_folder,filesep,master_filt_fname],'sig','fs');
sig = slave.sig;
save([slave_filt_folder,filesep,slave_filt_fname],'sig','fs');


