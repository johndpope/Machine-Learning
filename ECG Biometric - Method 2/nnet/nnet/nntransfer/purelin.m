function a = purelin(n,varargin)
%PURELIN Linear transfer function.
%	
% Transfer functions convert a neural network layer's net input into
% its net output.
%	
% A = <a href="matlab:doc purelin">purelin</a>(N) takes an SxQ matrix of S N-element net input column
% vectors and returns an SxQ matrix A of output vectors equal to N.
%
% Here a layer output is calculate from a single net input vector:
%
%   n = [0; 1; -0.5; 0.5];
%   a = <a href="matlab:doc purelin">purelin</a>(n);
%
% Here is a plot of this transfer function:
%
%   n = -5:0.01:5;
%   plot(n,<a href="matlab:doc purelin">purelin</a>(n))
%   set(gca,'dataaspectratio',[1 1 1],'xgrid','on','ygrid','on')
%
% Here this transfer function is assigned to the ith layer of a network:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = '<a href="matlab:doc purelin">purelin</a>';
%
%	See also POSIN, SATLIN, SATLINS.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2012/08/21 01:05:35 $

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = purelin.apply(n);
