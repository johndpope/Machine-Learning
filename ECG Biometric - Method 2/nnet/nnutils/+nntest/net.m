function ok = net(net,x,xi,ai,ew,seed)
%NET Run all tests on a network

% Copyright 2010-2012 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai,t,ew,mask] = nntest.rand_problem(seed);
end

if nargin == 1, clc, end
disp(' ')
disp(['================================ NNTEST.NET(' num2str(seed) ') Testing...'])
disp(' ')
if nargin == 1, nntest.disp_problem(net,x,xi,ai,t,ew,mask,seed); disp(' '); end

setdemorandstream(seed);
ok = test_net(net,x,xi,ai,t,ew,mask,seed);

if ok, result = 'PASSED'; else result = 'FAILED'; end
disp(' ')
disp(['================================ NNTEST.NET(' num2str(seed) ') *** ' result ' ***'])
disp(' ')

% ====================================================================

function ok = test_net(net,x,xi,ai,t,ew,mask,seed)

% Simulation
ok = nntest.sim(net,x,xi,ai,t,ew,mask,seed);
if ~ok, return, end

% Gradients
ok = nntest.calc(net,x,xi,ai,t,ew,mask,seed);
if ~ok, return, end

% Deployment Code Generation
ok = nnet.test.deployment(net,x,xi,ai,seed);

% ====== VIEW TESTS ======

diagram = view(net);
diagram.setVisible(false);
diagram.dispose;

% ====================================================================
