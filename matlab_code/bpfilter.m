function [sig] = bpfilter(siguf,flkhz,fhkhz,srkhz);
sr=srkhz*1000;
fl=flkhz*1000;fh=fhkhz*1000;
if fh>.905*sr/2
    fh=.905*sr/2;
end    
Wp=[fl fh]/(sr/2);
Ws=[.90*fl 1.1*fh]/(sr/2);
Rp=1;Rs=40;
[n,Wn]=ellipord(Wp,Ws,Rp,Rs);
[b,a]=ellip(n,Rp,Rs,Wn);
sig=filter(b,a,siguf);