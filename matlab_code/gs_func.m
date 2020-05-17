function pos_final = gs_func(mic_loc,Tm0,Tm_head,idx_ref,c)
% Use GS algorithm + for array localization
% Note the second step requires the delay from source to mic that 
% most array recordings don't have
%
% INPUT
%   mic_loc   location of mics
%   Tm0       time of arrival differences between reference channel on 
%             far-field array to all channels on far-field array
%   Tm_head   time of arrival differences between source and all channels
%             on far-field array
%   idx_ref   channel index of reference mic
%   c         sound speed
%
% Reference: Gillette and Silverman 2008, IEEE Sig Proc Let
% "A linear closed-Form algorithm for source localization from
% time-differences of arrival"
%
% Wu-Jung Lee | leewujung@gmail.com
% 2017 01 01

dm0 = Tm0*c;  % convert from delay to distance [m]
Dm_head = Tm_head*c;  % convert from delay to distance [m]

% GS algorithm
A = [mic_loc(idx_ref,1)-mic_loc(:,1),...
     mic_loc(idx_ref,2)-mic_loc(:,2),...
     mic_loc(idx_ref,3)-mic_loc(:,3),...
     dm0];
A(idx_ref,:) = [];

wm0 = 1/2*(dm0.^2 -mic_loc(:,1).^2+mic_loc(idx_ref,1).^2-...
                   mic_loc(:,2).^2+mic_loc(idx_ref,2).^2-...
                   mic_loc(:,3).^2+mic_loc(idx_ref,3).^2);
wm0(idx_ref,:) = [];

pos = A\wm0;  % Only use dimension 1 and 2 because the array is 2D only


% Calculate source z loc
x = pos(1);
y = pos(2);
z0 = 5;
d = Dm_head-dm0(idx_ref);
f = @(z)distfun(z,x,y,d,mic_loc);
z = lsqnonlin(f,z0);


% Final 3D position
pos_final = [x,y,z];





