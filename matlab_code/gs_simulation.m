% 2016 12 23  GS array localization algorithm simulation

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

% mic_loc = [rand(mic_len,1),rand(mic_len,1),rand(mic_len,1)*0.01];
% mic_loc = [mic_loc(:,1:2),rand(mic_len,1)*0.01];

c = 1500;

% Get DDOA
xyzm = mic_loc - repmat([x_s,y_s,z_s],mic_len,1);
Dm = sqrt(diag(xyzm*xyzm'));
dm0 = Dm - Dm(idx_ref);
% dm0 = dm0+rand(length(dm0),1)*0.01;

% Construct A
A = [mic_loc(idx_ref,1)-mic_loc(:,1),...
     mic_loc(idx_ref,2)-mic_loc(:,2),...
     mic_loc(idx_ref,3)-mic_loc(:,3),...
     dm0];
A(idx_ref,:) = [];

wm0 = 1/2*(dm0.^2 -mic_loc(:,1).^2+mic_loc(idx_ref,1).^2-...
                   mic_loc(:,2).^2+mic_loc(idx_ref,2).^2-...
                   mic_loc(:,3).^2+mic_loc(idx_ref,3).^2);
wm0(idx_ref,:) = [];

pos = A\wm0;

% A_c = inv(A'*A)*A';


% % 2D version ===========================
% % Get DDOA
% xyzm = mic_loc(:,1:2) - repmat([x_s,y_s],mic_len,1);
% Dm = sqrt(diag(xyzm*xyzm'));
% dm0 = Dm - Dm(idx_ref);
% 
% % Construct A
% A = [mic_loc(idx_ref,1)-mic_loc(:,1),...
%      mic_loc(idx_ref,2)-mic_loc(:,2),...
%      dm0];
% A(idx_ref,:) = [];
% 
% wm0 = 1/2*(dm0.^2 -mic_loc(:,1).^2+mic_loc(idx_ref,1).^2-...
%                    mic_loc(:,2).^2+mic_loc(idx_ref,2).^2);
% wm0(idx_ref,:) = [];
% 
% pos = A\wm0;


% Calculate z length
x = pos(1);
y = pos(2);
z0 = 5;
d = Dm;
f = @(z)distfun(z,x,y,d,mic_loc);
z = lsqnonlin(f,z0);







