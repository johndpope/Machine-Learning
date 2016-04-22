function [out1,out2] = traincgf(varargin)
%TRAINCGF Conjugate gradient backpropagation with Fletcher-Reeves updates.
%
%  <a href="matlab:doc traincgf">traincgf</a> is a network training function that updates weight and
%  bias values according to the conjugate gradient backpropagation
%  with Fletcher-Reeves updates.
%
%  [NET,TR] = <a href="matlab:doc traincgf">traincgf</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%  
%  [NET,TR] = <a href="matlab:doc traincgf">traincgf</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show             25  Epochs between displays
%    showCommandLine   0 generate command line output
%    showWindow        1 show training GUI
%    epochs          100  Maximum number of epochs to train
%    goal              0  Performance goal
%    time            inf  Maximum time to train in seconds
%    min_grad       1e-6  Minimum performance gradient
%    max_fail          5  Maximum validation failures
%    searchFcn 'srchcha'  Name of line search routine to use.
%
% Parameters related to line search methods (not all used for all methods):
%   scal_tol         20  Divide into delta to determine tolerance for linear search.
%   alpha         0.001  Scale factor which determines sufficient reduction in perf.
%   beta            0.1  Scale factor which determines sufficiently large step size.
%   delta          0.01  Initial step size in interval location step.
%   gama            0.1  Parameter to avoid small reductions in performance. Usually set
%                                       to 0.1. (See use in SRCH_CHA.)
%   low_lim         0.1  Lower limit on change in step size.
%   up_lim          0.5  Upper limit on change in step size.
%   maxstep         100  Maximum step length.
%   minstep      1.0e-6  Minimum step length.
%   bmax             26  Maximum step size.
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'traincgf';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM,
%           TRAINCGP, TRAINCGB, TRAINSCG, TRAINOSS,
%           TRAINBFG.

% Updated by Orlando De Jes�s, Martin Hagan, 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.24 $ $Date: 2013/05/13 23:10:15 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Training Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  nnassert.minargs(nargin,1);
  in1 = varargin{1};
  if ischar(in1)
    switch (in1)
      case 'info'
        out1 = INFO;
      case 'apply'
        [out1,out2] = train_network(varargin{2:end});
      case 'formatNet'
        out1 = formatNet(varargin{2});
      case 'check_param'
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if isempty(err)
          err = check_param(param);
        end
        if nargout > 0
          out1 = err;
        elseif ~isempty(err)
          nnerr.throw('Type',err);
        end
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    net = varargin{1};
    oldTrainFcn = net.trainFcn;
    oldTrainParam = net.trainParam;
    if ~strcmp(net.trainFcn,mfilename)
      net.trainFcn = mfilename;
      net.trainParam = INFO.defaultParam;
    end
    [out1,out2] = train(net,varargin{2:end});
    net.trainFcn = oldTrainFcn;
    net.trainParam = oldTrainParam;
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info()
  isSupervised = true;
  usesGradient = true;
  usesJacobian = false;
  usesValidation = true;
  supportsCalcModes = true;
  info = nnfcnTraining(mfilename,'Conjugate Gradient Backpropagation with Fletcher-Reeves Restarts',8.0,...
    isSupervised,usesGradient,usesJacobian,usesValidation,supportsCalcModes,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_int_scalar',1000,...
    'Maximum number of training iterations before training is stopped.') ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.') ...
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.') ...
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-10,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('searchFcn','Line search function','nntype.search_fcn','srchcha',...
    'Line search function used to optimize performance each epoch.') ...
    nnetParamInfo('scale_tol','Scale Tolerance','nntype.pos_scalar',20,...
    'Scale tolerance used for line search.') ...
    ...
    nnetParamInfo('alpha','Alpha','nntype.pos_scalar',0.001,...
    'Alpha.') ...
    nnetParamInfo('beta','Beta','nntype.pos_scalar',0.1,...
    'Beta.') ...
    nnetParamInfo('delta','Delta','nntype.pos_scalar',0.01,...
    'Delta.') ...
    nnetParamInfo('gama','Gamma','nntype.pos_scalar',0.1,...
    'Gamma.') ...]) ...
    nnetParamInfo('low_lim','Lower Limit','nntype.pos_scalar',0.1,...
    'Lower limit.') ...
    nnetParamInfo('up_lim','Upper Limit','nntype.pos_scalar',0.5,...
    'Upper limit.') ...
    nnetParamInfo('max_step','Maximum Step','nntype.pos_scalar',100,...
    'Maximum step.') ...
    nnetParamInfo('min_step','Minimum Step','nntype.pos_scalar',1.0e-6,...
    'Minimum step.') ...
    nnetParamInfo('bmax','B Max','nntype.pos_scalar',26,...
    'B Max.'), ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    nntraining.state_info('a','Step Size','continuous','log') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function net = formatNet(net)
  if isempty(net.performFcn)
    warning('nnet:traincgf:Performance',nnwarning.empty_performfcn_corrected);
    net.performFcn = 'mse';
  end
end

function [calcNet,tr] = train_network(archNet,rawData,calcLib,calcNet,tr)
  
  % Parallel Workers
  isParallel = calcLib.isParallel;
  isMainWorker = calcLib.isMainWorker;
  mainWorkerInd = calcLib.mainWorkerInd;

  % Create broadcast variables
  stop = []; 
  X = [];
  dX = [];
  dperf = [];
  delta = [];
  tol = [];
  ch_perf = [];  

  % Initialize
  param = archNet.trainParam;
  if isMainWorker
      startTime = clock;
      original_net = calcNet;
  end
  
  [perf,vperf,tperf,gX,gradient] = calcLib.perfsGrad(calcNet);
    
  if isMainWorker
      gX = -gX;
      [best,val_fail] = nntraining.validation_start(calcNet,perf,vperf);
      X = calcLib.getwb(calcNet);
      num_X = length(X);

      delta = param.delta;
      tol = delta/param.scale_tol;
      a=1;

      % Training Record
      tr.best_epoch = 0;
      tr.goal = param.goal;
      tr.states = {'epoch','time','perf','vperf','tperf','gradient','val_fail','a'};

      % Status
      status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
        nntraining.status('Performance','','log','continuous',best.perf,param.goal,best.perf) ...
        nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
        nntraining.status('Validation Checks','','linear','discrete',0,param.max_fail,0) ...
        nntraining.status('Step Size','','log','continuous',param.max_step,param.min_step,a) ...
        ];
      nnet.train.feedback('start',archNet,tr,calcLib.options,status);
  end

  %% Train
  for epoch=0:param.epochs
      if isMainWorker
        % Performance, Gradient and Search Direction
        if (epoch==0)
          % First Iteration

          % Initial performance
          perf_old = perf;
          ch_perf = perf;
          sum1 = 0; sum2 = 0;

          % Initial gradient and norm of gradient
          norm_sqr = gX'*gX;
          gradient = sqrt(norm_sqr);
          dX_old = -gX;

          % Initial search direction and initial slope
          if gradient == 0,
              dX = -gX;
          else 
              dX = -gX/gradient;
          end
          dperf = gX'*dX;

        else

          % After first iteration

          % Calculate change in performance and norm of gradient
          normnew_sqr = gX'*gX;
          gradient = sqrt(normnew_sqr);
          ch_perf = perf - perf_old;

          % Calculate search direction modification parameter
          if rem(epoch,num_X)==0 || norm_sqr==0,
            Z=0;
          else
            Z=normnew_sqr/norm_sqr;
          end

          % Calculate new search direction
          dX = -gX + dX_old*Z;

          % Save new directions and norm of gradient
          %gX_old = gX;
          dX_old = dX;
          norm_sqr = normnew_sqr;
          perf_old = perf;

          % Normalize search direction
          norm_dX = norm(dX);
          if norm_dX~=0, dX = dX/norm_dX; end;

          % Check for a descent direction
          dperf = gX'*dX;
          if (dperf >= 0)
            if gradient==0,
              dX = -gX;
            else
              dX = -gX/gradient;
            end
            dX_old = -gX;
            dperf = gX'*dX;
          end
        end
      
        % Stopping Criteria
        current_time = etime(clock,startTime);
        [userStop,userCancel] = nntraintool('check');
        if userStop, tr.stop = 'User stop.'; calcNet = best.net;
        elseif userCancel, tr.stop = 'User cancel.'; calcNet = original_net;
        elseif (perf <= param.goal), tr.stop = 'Performance goal met.'; calcNet = best.net;
        elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; calcNet = best.net;
        elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; calcNet = best.net;
        elseif (gradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; calcNet = best.net;
        elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; calcNet = best.net;
        elseif (a == 0), tr.stop = 'Minimum step size reached.'; calcNet = best.net;
        end

        % Feedback
        tr = nnet.trainingRecord.update(tr,...
          [epoch current_time perf vperf tperf gradient val_fail a]);
        statusValues = [epoch,current_time,best.perf,gradient,val_fail a];
        nnet.train.feedback('update',archNet,tr,calcLib.options,rawData,calcLib,calcNet,best.net,status,statusValues);
        stop = ~isempty(tr.stop);
      end
        
    % Stop
    if isParallel, stop = labBroadcast(mainWorkerInd,stop); end
    if stop, break, end

    % Minimize the performance along the search direction
    [a,gX,perf,retcode,delta,tol] = ...
      feval(param.searchFcn,calcLib,calcNet,dX,gX,perf,dperf,delta,tol,ch_perf,param);

    % Keep track of the number of function evaluations
    if isMainWorker
        sum1 = sum1 + retcode(1);
        sum2 = sum2 + retcode(2);
        
        % Update X
        X = X + a*dX;
    end
    
    calcNet = calcLib.setwb(calcNet,X);

    % Validation
    [perf,vperf,tperf] = calcLib.trainValTestPerfs(calcNet);
    
    if isMainWorker
        [best,tr,val_fail] = nntraining.validation(best,tr,val_fail,calcNet,perf,vperf,epoch);
    end
  end
end

