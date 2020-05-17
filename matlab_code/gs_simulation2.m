% 2016 12 23  GS array localization algorithm simulation
% 2017 01 01  Test gs_func using simulation

load('/Users/wujung/Dropbox/0_CODE/grampus_click_code/farfield_array_loc.mat');

% Source locations
% z_s = (0.5:0.1:2.5)';
% x_s = rand(length(z_s),1)+0.5;
% y_s = rand(length(z_s),1)+0.5;

x_s = 1.25;
y_s = 1.5;
z_s = 2;

ref_mic_num = 1;
idx_ref = find(ref_mic_num==mic_num);
mic_len = length(mic_num);

c = 1500;

% Get DDOA
xyzm = mic_loc - repmat([x_s,y_s,z_s],mic_len,1);
Dm = sqrt(diag(xyzm*xyzm'))+rand(size(Dm))*0.01;

Tm0 = (Dm-Dm(idx_ref))/1500;
Tm_head = Dm/1500;

pos_final = gs_func(mic_loc,Tm0,Tm_head,idx_ref,c);

