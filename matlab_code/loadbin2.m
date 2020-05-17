function [sig, FILENAME, PATHNAME] = LoadBin2

[FILENAME, PATHNAME] = uigetfile('*.*');
cd(eval(['PATHNAME']));

fid=fopen(FILENAME);

[sig,COUNT] = fread (fid,inf,'int16');