function obs_fcn(fcn,varargin)
%NNTOBSF Warn that a function is obsolete.
%
%  nnerr.obs_fcn(fcnName,line1,line2,...)
%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $

w = warning('query','NNET:Obsolete');
if ~strcmp(w.state,'on'), return, end

NNTWARNFLAG = nntwarn('query');
if isempty(NNTWARNFLAG)
  warning('NNET:Obsolete',[upper(fcn) ' is an obsolete function.'])
  for i=1:length(varargin)
    disp(['          ' varargin{i}])
  end
  disp(' ')
elseif strcmp(NNTWARNFLAG,'error')
  nnerr.throw('Obsolete',[upper(fcn) ' is an obsolete function.'])
end
