function diffd = distfun(z,x,y,d,mic_loc)

diffd = sqrt((x-mic_loc(:,1)).^2 +...
             (y-mic_loc(:,2)).^2 +...
             (z-mic_loc(:,3)).^2) - d;


