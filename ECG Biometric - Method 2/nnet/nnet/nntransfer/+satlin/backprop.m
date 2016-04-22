function dn = backprop(da,n,a,param)
%PURELIN.BACKPROP

% Copyright 2012 The MathWorks, Inc.

dn = bsxfun(@times,da,(n >= 0) & (n <= 1));
