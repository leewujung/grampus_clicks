% 2016 07 04  Extract clicks from sound files

% Files to filter
%trial = '20150426_pm';
%trial = '20150427_am';

% ====== 20150426_am ========
% trial = '20150426_am';
% throw = 1;
% file_want_idx = 60:62;  % throw 1
% throw = 3;
% file_want_idx = 92;  % throw 3
% ====== 20150426_pm ========
trial = '20150426_pm';
% throw = 1;
% file_want_idx = 102:103;  % throw 1
throw = 2;
file_want_idx = 111:112;  % throw 1
% ====== 20150427_am ========
% trial = '20150427_am';
% throw = 1;
% file_want_idx = 51:52;  % throw 1
% throw = 2;
% file_want_idx = 64:65;  % throw 2
% throw = 3;
% file_want_idx = 74:75;  % throw 3
% throw = 4;
% file_want_idx = 94:95;  % throw 4


param.trial = trial;
param.file_extracted = file_want_idx;


% Path to acoustic data
if isunix
    base_data_folder = '/Volumes/wjlee_apl_2/grampus_data';
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
    base_data_folder = 'F:\grampus_data';
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


% Path to save data
if isunix
    base_save_folder = '/Volumes/wjlee_apl_2/grampus_analysis/ANALYSIS';
else
    base_save_folder = 'F:\Dropbox\Z_wjlee\projects\grampus_suction_cup\ANALYSIS\';
end


% Use script name for saving files
[~,script_name,~] = fileparts(mfilename('fullpath'));
save_path = fullfile(base_save_folder,script_name);
if ~exist(save_path,'dir')
    mkdir(save_path);
end


% Re-arrange channel according to sequence on head
switch trial
  case '20150426_am'
    chseq = [4,7,6,5,1,2,3;    % channel sequence according to column 2
             1,2,3,4,5,6,7]';  % location on animals' head
  case '20150426_pm'
    chseq = [5,7,6,4,3,2,1;
             1,2,3,4,5,6,7]';
  case '20150427_am'
    chseq = [5,7,6,4,1,2,3;
             1,2,3,4,5,6,7]';
%     chseq = [5,7,6,4,2,1,3;
%              1,2,3,4,5,6,7]';
end
param.chseq_ch_on_head = chseq;  % order of channels on dolphin head

chseq = sortrows(chseq,1);
param.chseq = chseq;  % ch sequence idx to rearrange channels
                      % according to position on dolphin head


% Set click length to extract
ex_pts = -500:1000;
ex_len = length(ex_pts);
ch_wanted = [1:7];

param.ex_pts = ex_pts;
param.ch_wanted = ch_wanted;

% Process each file
click_extracted = cell(length(file_want_idx),1);
detected_param = cell(length(file_want_idx),1);
for iF=1:length(file_want_idx)
    % Load data
    m_fname = sprintf('%s_%04d_filt_%s',m_file_pre,file_want_idx(iF),file_post);
    ss = strsplit(m_fname,'.');
    m_det_fname = [ss{1},'_detect.mat'];

    disp(['Processing ',m_fname]);

    load(fullfile(base_data_folder,m_folder,m_fname));
    load(fullfile(base_data_folder,m_folder,m_det_fname));

    filter_folder = '/Volumes/wjlee_apl_2/grampus_analysis/ANALYSIS';
    lpf_fname = 'lpf_140-200kHz_equiripple40dB.mat';
    load([filter_folder,filesep,lpf_fname]);

    sig(:,2) = filtfilt(lpf_num,1,sig(:,2));  % lowpass
    
    % Re-arrange channel sequence according to position on head
    sig_chseq = sig(:,chseq(:,2)');
    sig_chseq = sig_chseq(:,ch_wanted);

    % Extract clicks
    click_num = length(call);
    click_ex = nan(click_num,length(ch_wanted),ex_len);
    for iC=1:click_num
        if call(iC).locs+ex_pts(end)>length(sig_chseq)
            len_append = call(iC).locs+ex_pts(end)-length(sig_chseq);
            click_curr = [sig_chseq(call(iC).locs+ex_pts(1):end,:);...
                          zeros(len_append,length(ch_wanted))];
        elseif call(iC).locs+ex_pts(1)<1
            len_append = abs(call(iC).locs+ex_pts(1))+1;
            click_curr = [sig_chseq(1:call(iC).locs+ex_pts(end),:);...
                          zeros(len_append,length(ch_wanted))];
            
        else
            click_curr = sig_chseq(call(iC).locs+ex_pts,:);
        end
        click_ex(iC,:,:) = click_curr';
    end
    click_extracted{iF} = click_ex;

    % Save basic params
    if iF==1 % if processing first file
        param.sig_pts_per_file = size(sig,1);
        param.fs = fs;
    end

    detected_param{iF} = call;
end

save_fname = sprintf('%s_%s_throw%d_file%03d-%03d',...
                     script_name,trial,throw,file_want_idx(1),file_want_idx(end));
save(fullfile(save_path,save_fname),'param','click_extracted','detected_param');



