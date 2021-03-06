function dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ
% z = SxQ

[S,Q] = size(z);
R = size(p,1);

p = reshape(p',1,Q,1,R); % 1xQx1xR
w = reshape(w,S,1,1,R); % Sx1x1xR

z1 = bsxfun(@minus,w,p); % SxQx1xR

d = sign(z1); % SxQx1xR

dw = zeros(S,Q,S,R); % SxQxSxR
for i=1:S
  dw(i,:,i,:) = d(i,:,1,:);
end
