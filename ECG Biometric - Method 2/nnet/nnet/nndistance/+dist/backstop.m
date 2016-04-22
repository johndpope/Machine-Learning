function dw = backstop(dz,w,p,z,param)
%DOTPROD.BACKSTOP

% Copyright 2012 The MathWorks, Inc.

[S,Q] = size(dz);
R = size(p,1);

p = reshape(p,1,R,Q);
z = reshape(z,S,1,Q);
dz = reshape(dz,S,1,Q);

z(z==0) = 1;
d = bsxfun(@rdivide,bsxfun(@minus,w,p),z);
d(isnan(d)) = 0;

dw = sum(bsxfun(@times,d,dz),3);
