function a = apply(n,param)
%PURELIN.APPLY

% Copyright 2012 The MathWorks, Inc.

a = max(-1,min(1,n));
a(isnan(n)) = nan;
