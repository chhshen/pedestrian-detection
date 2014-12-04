function [scales,scaleshw] = getScales(nPerOct,nOctUp,minDs,shrink,sz)
% set each scale s such that max(abs(round(sz*s/shrink)*shrink-sz*s)) is
% minimized without changing the smaller dim of sz (tricky algebra)
if(any(sz==0)), scales=[]; scaleshw=[]; return; end
nScales = floor(nPerOct*(nOctUp+log2(min(sz./minDs)))+1);
scales = 2.^(-(0:nScales-1)/nPerOct+nOctUp);
if(sz(1)<sz(2)), d0=sz(1); d1=sz(2); else d0=sz(2); d1=sz(1); end
for i=1:nScales, s=scales(i);
  s0=(round(d0*s/shrink)*shrink-.25*shrink)./d0;
  s1=(round(d0*s/shrink)*shrink+.25*shrink)./d0;
  ss=(0:.01:1-eps)*(s1-s0)+s0;
  es0=d0*ss; es0=abs(es0-round(es0/shrink)*shrink);
  es1=d1*ss; es1=abs(es1-round(es1/shrink)*shrink);
  [~,x]=min(max(es0,es1)); scales(i)=ss(x);
end
kp=[scales(1:end-1)~=scales(2:end) true]; scales=scales(kp);
scaleshw = [round(sz(1)*scales/shrink)*shrink/sz(1);
  round(sz(2)*scales/shrink)*shrink/sz(2)]';