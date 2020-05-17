% 2016 07 12  Match clicks recorded on suction cups and far-field hydrophones

clear
addpath('~/Dropbox/0_CODE/MATLAB/saveSameSize');

%trial = '20150426_am';
trial = '20150426_pm';
%trial = '20150427_am';
throw = 1;

trial_throw = sprintf('%s_throw_%d',trial,throw);

cup = load('


% Path to data
if isunix
    base_data_folder = '~/internal_2tbDropbox/Z_wjlee/grampus_suction_cup/ANALYSIS';
    %base_folder = '~/Dropbox/Z_wjlee/grampus_suction_cup/ANALYSIS';
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
