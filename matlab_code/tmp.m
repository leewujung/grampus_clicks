% tmp: rename files from master_* to slave_*

folder = '/home/wu-jung/internal_2tb/grampus_data/20150427/trial1_am/slave_matfiles_filt';
files = dir(fullfile(folder,'*.mat'));

for iF=1:length(files)
    ss = strsplit(files(iF).name,'_');
    ss{1} = 'slave';
    fname_new = strjoin(ss,'_');
    movefile(fullfile(folder,files(iF).name),...
             fullfile(folder,fname_new));
end