%suction cup hydrophone signals
clear all;
jclk=[];ns=1;npts=1024;i=1;j=0;
gain=42;
vconv=10/(2^15);
sr=500000;srkhz=500;dt=1/sr;dtus=dt*1e06;
%nbits=16;npts=2048;thold=0.2;mpts=512;
%dfkhz=sr/mpts/1000;nf=fix(160/dfkhz);dt=1/sr;dtms=dt*1000;
%fkhz=0:dfkhz:(nf-1)*dfkhz;
%fkhz=fkhz';                     %change to column vector
flkhz=15;fhkhz=150;ns=1;j=0;ioffset=-50;
disp('BROWSE FOR FILE TO READ ')
[data,fn,pn]=loadbin2;
data=data*vconv;
%    sig=sig*vconv;  

sig=bpfilter(data,flkhz,fhkhz,srkhz);
sm=mean(sig);
sig=sig-sm;
lensig=length(sig);
i=ioffset+1
disp('MOVE Y CURSOR TO THRESHOLD VALUE ')
plot(sig);[x,y]=ginput(1)
%thold=input(' enter treshold value ')
thold=y;
while ns==1
    if i<=0
        i=1;
    end    
    if i< lensig-npts;
        if sig(i)>thold
            j=j+1;
            figure (1);
            istart=i+ioffset; istop=istart+npts/2-1;
            xig=sig(istart:istop);
            plot(xig)
            nplot=int2str(j);
            title(nplot);  
            i=istop;
            pause (.2)
        end 
        i=i+1;
    end    
    if i==lensig-npts
        ns=0;
        break;
    end
end  

%subplot(5,1,1);plot(slpp);
%subplot(5,1,2);plot(se);
%subplot(5,1,3);plot(ici);
%subplot(5,1,4);plot(fo);
%subplot(5,1,5);plot(beta);
%mode(j)=1
%disp('save results (y or n)? ')

