% 2016 07 02  Figure out which audio files contain clicks

% ============ 20150426 am ============
% video_flash_time = 4;  % sec
% video_want_raw = '5:08';  % min:sec  % 20150426 am, trial 1, throw 1
% video_want_raw = '6:32';  % min:sec  % 20150426 am, trial 1, throw 2
% video_want_raw = '7:44';  % min:sec  % 20150426 am, trial 1, throw 3

% ============ 20150426 pm ============
% video_flash_time = 4;  % sec
% video_want_raw = '8:34';  % min:sec  % 20150426 pm, trial 2, throw 1
% video_want_raw = '9:20';  % min:sec  % 20150426 pm, trial 2, throw 2

% ============ 20150427 am ============
video_flash_time = 7;  % sec
% video_want_raw = '4:22';  % min:sec  % 20150427 am, trial 1, throw 1
% video_want_raw = '5:29';  % min:sec  % 20150427 am, trial 2, throw 2
video_want_raw = '6:18';  % min:sec  % 20150427 am, trial 2, throw 3
% video_want_raw = '8:00';  % min:sec  % 20150427 am, trial 2, throw 4

video_want_dum = strsplit(video_want_raw,':');
video_want_sec = str2num(video_want_dum{1})*60+str2num(video_want_dum{2});

sound_file_cut = 5;  % sec for splitting sound file
sound_file_dum = ceil(video_want_sec/sound_file_cut);
sound_file_want = sound_file_dum-1;

