function param = parameterInfo

% Copyright 2012 The MathWorks, Inc.

param = ...
  [...
  nnetParamInfo('alpha','Alpha Multiplier','nntype.real_scalar',2,...
  'Gain on net sum.'),...
  nnetParamInfo('beta','Beta Offset','nntype.real_scalar',1,...
  'Offset for net sum.'),...
  ];

