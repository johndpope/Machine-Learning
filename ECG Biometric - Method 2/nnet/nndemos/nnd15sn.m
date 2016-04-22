function nnd15sn(cmd,arg1,arg2,arg3)
%NND15SN Shunting network demonstration.
%
%  View the response of a shunting network for different inputs,
%  biases and time constants.

% $Revision: 1.6.2.4 $
% Copyright 1994-2011 Martin T. Hagan
% First Version, 8-31-95.

%==================================================================

% GLOBALS
global pp;
global pn;
global bp;
global bn;
global e;

% CONSTANTS
me = 'nnd15sn';
Fs = 8192;

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig = nndfgflg(me);
if ~isempty(fig) && isempty(get(fig,'children')), fig = []; end

% GET WINDOW DATA IF IT EXISTS
if ~isempty(fig)
  H = get(fig,'userdata');
  fig_axis = H(1);         % window axis
  desc_text = H(2);        % handle to first line of text sequence
  big_axis = H(3);         % Big axis
  pp_bar = H(4);
  pp_text = H(5);
  pn_bar = H(6);
  pn_text = H(7);
  bp_bar = H(8);
  bp_text = H(9);
  bn_bar = H(10);
  bn_text = H(11);
  e_bar = H(12);
  e_text = H(13);
  old_ptr = H(14);
  last_ptr = H(15);
  big_line = H(16);
end

%==================================================================
% Activate the window.
%
% ME() or ME('')
%==================================================================

if strcmp(cmd,'')
  if ~isempty(fig)
    figure(fig)
    set(fig,'visible','on')
  else
    feval(me,'init')
  end

%==================================================================
% Close the window.
%
% ME() or ME('')
%==================================================================

elseif strcmp(cmd,'close') & ~isempty(fig)
  delete(fig)

%==================================================================
% Initialize the window.
%
% ME('init')
%==================================================================

elseif strcmp(cmd,'init') & isempty(fig)

  % CONSTANTS
  pp = 1;
  pn = 0;
  bp = 1;
  bn = 0;
  e = 1;

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Shunting Network','','Chapter 15');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    ... % 'Backing_Store','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(15,458,363,'shadow')

  % EXCITITORY INPUT SLIDER BAR
  x = 40;
  y = 150;
  len = 140;
  text(x,y,'Input p+:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  pp_text = text(x+len,y,sprintf('%3.1f',pp),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'10.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  pp_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''pp'')'],...
    'min',0,...
    'max',10,...
    'value',pp);

  % INHIBITORY INPUT SLIDER BAR
  x = 40;
  y = 100;
  len = 140;
  text(x,y,'Input p-:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  pn_text = text(x+len,y,sprintf('%3.1f',pn),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'10.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  pn_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''pn'')'],...
    'min',0,...
    'max',10,...
    'value',pn);

  % EXCITITORY BIAS SLIDER BAR
  x = 210;
  y = 150;
  len = 140;
  text(x,y,'Bias b+:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  bp_text = text(x+len,y,sprintf('%3.1f',bp),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'5.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  bp_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''bp'')'],...
    'min',0,...
    'max',5,...
    'value',bp);

  % INHIBITORY BIAS SLIDER BAR
  x = 210;
  y = 100;
  len = 140;
  text(x,y,'Bias b-:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  bn_text = text(x+len,y,sprintf('%3.1f',bn),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'5.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  bn_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''bn'')'],...
    'min',0,...
    'max',5,...
    'value',bn);

  % TIME CONSTANT SLIDER BAR
  x = 40;
  y = 50;
  len = 310;
  text(x,y,'Time Constant (eps):',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  e_text = text(x+len,y,sprintf('%3.1f',e),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.1',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'5.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  e_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''time'')'],...
    'min',0.1,...
    'max',5,...
    'value',e);

  % BIG AXES
  big_axis = nnsfo('a1','Response','Time','Output n');
  set(big_axis,...
    'position',[50 190 300 140],...
    'xlim',[-0.1 5.1],...
    'xtick',0:5,...
    'ylim',[-5.5 5.5],...
    'ytick',-5:2.5:5)
  big_line = plot([0 5],[0 0],'--',...
    'color',nndkblue,...
    'CreateFcn','');

  % PLOT RESPONSE
  [T,Y] = ode45('nndshunt',[0 5],0);
  last = plot(T,Y,...
    'color',nnred,...
    'linewidth',2,...
    'CreateFcn','');

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 130 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[410 95 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 60 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % SAVE WINDOW DATA AND LOCK
  old_ptr = uicontrol('visible','off','userdata',[]);
  last_ptr = uicontrol('visible','off','userdata',last);

  H = nndArray({fig_axis, ...
       desc_text,...
       big_axis, ...
       pp_bar pp_text pn_bar pn_text, ...
       bp_bar bp_text bn_bar bn_text e_bar e_text,...
       old_ptr, last_ptr, ...
       big_line});

  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(me,'instr');

  % LOCK WINDOW
  set(fig,...
   'nextplot','new',...
   'color',nnltgray);

  nnchkfs;

%==================================================================
% Display the instructions.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'instr') & ~isempty(fig)
  nnsettxt(desc_text,...
    'Use the slider bars',...
    'to adjust the inputs,',...
    'biases and time',...
    'constant.',...
    '',...
    'Click [Clear] to',...
    'remove old',...
    'responses.')
    
%==================================================================
% Clear input vectors.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & ~isempty(fig) & (nargin == 1)
  
  % GET DATA
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % REMOVE OLD
  set(old,'color',nnltyell);
  drawnow
  set(last,'color',nnred)
  drawnow
  delete(old);
  set(big_line,'color',nndkblue);

  % NEW LINE

  % SAVE DATA
  set(old_ptr,'userdata',[]);

%==================================================================
% Respond to excitatory input slider.
%
% ME('pp')
%==================================================================

elseif strcmp(cmd,'pp')
  
  % GET DATA
  pp = get(pp_bar,'value');
  set(pp_bar,'value',pp);

  % UPDATE BAR
  set(pp_text,'string',sprintf('%3.1f',pp))

  % UPDATE RESPONSE
  cmd = 'update';

%==================================================================
% Respond to inhibitory input slider.
%
% ME('pn')
%==================================================================

elseif strcmp(cmd,'pn')
  
  % GET DATA
  pn = get(pn_bar,'value');

  % UPDATE BAR
  set(pn_text,'string',sprintf('%3.1f',pn))

  % UPDATE RESPONSE
  cmd = 'update';

%==================================================================
% Respond to upper bias slider.
%
% ME('bp')
%==================================================================

elseif strcmp(cmd,'bp')
  
  % GET DATA
  bp = get(bp_bar,'value');

  % UPDATE BAR
  set(bp_text,'string',sprintf('%3.1f',bp))

  % UPDATE RESPONSE
  cmd = 'update';

%==================================================================
% Respond to lower bias slider.
%
% ME('bn')
%==================================================================

elseif strcmp(cmd,'bn')
  
  % GET DATA
  bn = get(bn_bar,'value');

  % UPDATE BAR
  set(bn_text,'string',sprintf('%3.1f',bn))

  % UPDATE RESPONSE
  cmd = 'update';

%==================================================================
% Respond to time constant slider.
%
% ME('time')
%==================================================================

elseif strcmp(cmd,'time')
  
  % GET DATA
  e = get(e_bar,'value');

  % UPDATE BAR
  set(e_text,'string',sprintf('%3.1f',e))

  % UPDATE RESPONSE
  cmd = 'update';
end

%==================================================================
% Respond to time constant slider.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update')

  % GET DATA
  pp = get(pp_bar,'value');
  pn = get(pn_bar,'value');
  bp = get(bp_bar,'value');
  bn = get(bn_bar,'value');
  e = get(e_bar,'value');
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % MAKE LAST LINE OLD
  set(last,'color',nndkgray);
  old = [old; last];
  if length(old) > 3
    gone = old(1);
    old(1) = [];
  else
    gone = [];
  end
  set(gone,'color',nnltyell);
  set(old,'color',nnltgray)
  drawnow
  delete(gone);

  % CALCULATE RESPONSE
  [T,Y] = ode45('nndshunt',[0 5],0);

  % PLOT RESPONSE
  set(fig,'nextplot','add')
  axes(big_axis)
  last = plot(T,Y,...
    'color',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  set(big_line,'color',nndkblue);
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

end

