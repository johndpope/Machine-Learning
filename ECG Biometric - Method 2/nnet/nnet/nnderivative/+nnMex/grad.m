function [gWB,trainPerf,trainN] = grad(net,data,hints)

numMasks = 1;
switch hints.direction
  case {'default','backward'}
    [gWB,trainPerf,trainN] = nnMex.bg ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.trainMask,...
      data.Q,data.TS,numMasks,hints);
  case 'forward'
    [gWB,trainPerf,trainN] = nnMex.fg ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.trainMask,...
      data.Q,data.TS,numMasks,hints);
end
