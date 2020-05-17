% 2016 11 21  Extract clicks in cal data
clear

% Set param
sr=500000;srkhz=500;dt=1/sr;dtus=dt*1e06;
flkhz=15;fhkhz=150;ns=1;j=0;ioffset=-50;
vconv=10/(2^15);
sr=500000;srkhz=500;dt=1/sr;dtus=dt*1e06;
ioffset=-50;
click_len = 512;
idx_want = (1:click_len)+ioffset;

% Set path
cal_path = 'F:\grampus_data\calibration_whit\suction cup';
cal_file_all = dir(fullfile(cal_path,'*.dat'));
save_path = 'F:\grampus_data\calibration_whit\suction_cup_proc';

% Extract click from all files
for iH=1:length(cal_file_all)
    
    cal_file = cal_file_all(iH).name;
    
    % Load data
    fid = fopen(fullfile(cal_path,cal_file));
    [data,COUNT] = fread (fid,inf,'int16');
    data = data*vconv;
    
    sig = bpfilter(data,flkhz,fhkhz,srkhz);
    sm = mean(sig);
    sig = sig-sm;
    
    % Threshold to find signal
    th = max(sig)*0.8;
    [pks,locs] = findpeaks(sig,'MinPeakHeight',th,'MinPeakDistance',1e4);
    
    click = zeros(click_len,length(locs));
    for iC=1:length(locs)
        click(:,iC) = sig(locs(iC)+idx_want);
    end
    
    % Save extracted signal
    save(fullfile(save_path,[strtok(cal_file,'.'),'.mat']),'click','sr');
    
end % loop through all phones


