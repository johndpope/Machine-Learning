function nnd13os(cmd,arg1,arg2,arg3)
%NND13OS Outstar demonstration.
%
%  See a network learn to recall pineapple features after being trained
%  on several examples with the outstar rule.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or Neural Network Toolbox.

% $Revision: 1.7.2.6 $
% Copyright 1994-2011 Martin T. Hagan
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd13os';
Fs = 8192;
pause1 = 0.7;
pause2 = 0.1;

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
  lines = H(3:4);          % belt circle lines
  fruit_indicator = H(5);  % fruit entrance indicator
  top_indicator = H(6);    % top exit indicator
  bottom_indicator = H(7); % bottom exit indicator;
  sounds = H(8:15);        % pointers to sounds
  angle_ptr = H(16);       % angle (deg) of lines in conveyor ends
  fruit_ptr = H(17);       % pointer to fruit shape
  arrows = H(21:22);       % handles to arrows
  rb1 = H(23);             % Working radio button
  rb2 = H(24);             % Not working radio button
  cross = H(25);           % Not working cross
  p1_ptr = H(26);          % Input #1
  p2_ptr = H(27);          % Input #2
  a_ptr = H(28);           % Output
  W2_ptr = H(29);          % Weights #2
  p1_box1 = H(30);
  p1_text1 = H(31);
  p1_box2 = H(32);
  p1_text2 = H(33);
  p1_box3 = H(34);
  p1_text3 = H(35);
  p2_box = H(36);
  p2_text = H(37);
  a_box1 = H(38);
  a_text1 = H(39);
  a_box2 = H(40);
  a_text2 = H(41);
  a_box3 = H(42);
  a_text3 = H(43);
  go_button = H(44);
  mode_ptr = H(45);
  W2_box1 = H(46);
  W2_text1 = H(47);
  W2_box2 = H(48);
  W2_text2 = H(49);
  W2_box3 = H(50);
  W2_text3 = H(51);
  mode = get(mode_ptr,'userdata');
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

  % CHECK FOR TRANSFER FUNCTIONS
  if ~nnfexist(me), return, end

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Outstar','','Chapter 13');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    ... % 'Backing_Store','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % SOUND POINTERS
  wind = uicontrol('visible','off','userdata',nndsnd(3));
  knock = uicontrol('visible','off','userdata',nndsnd(5));
  scan = uicontrol('visible','off','userdata',nndsnd(1));
  classify = uicontrol('visible','off','userdata',nndsnd(4));
  blip = uicontrol('visible','off','userdata',nndsnd(6));
  bloop = uicontrol('visible','off','userdata',nndsnd(7));
  blp = uicontrol('visible','off','userdata',nndsnd(9));
  tribble = uicontrol('visible','off','userdata',nndsnd(8));

  % ICON
  nndicon(13,458,363,'shadow')

  % CONVEYOR BELT
  deg = pi/180;
  angle = [0:5:360]*deg;
  cx = cos(angle);
  cy = sin(angle);

  % ENTRANCE BOX
  x = 60;
  y = 20;
  fill([0 0 x+10 x+10],y+[70 50 50 70],nndkblue,...
    'edgecolor','none')
  fill(x+[10 10 50 50],y+[80 40 40 80],nndkblue,...
    'edgecolor','none')
  plot([0 x+[10 10 50 50 10 10] 0],...
    y+[50 50 40 40 80 80 70 70],...
    'color',nnred)
  left_arrow = fill(x+30+[-5 -5 -10 0 10 5 5],y+60+[15 5 5 -15 5 5 15],nndkblue,...
    'edgecolor',nnred,...
    'CreateFcn','');
  fruit_ind = text(x-25,y+60,'Fruit',...
    'color',[0.8 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'CreateFcn','');

  % LEFT CIRCLE
  line_angle = 45*deg;
  fill(x-10+cx*10,y+10+cy*10,nnred,...
    'edgecolor',nndkblue,...
    'linewidth',2)
  line_1 = plot(x-10+cos([0 pi]+line_angle)*8,y+10+sin([0 pi]+line_angle)*8,...
    'color',nndkblue,...
    'CreateFcn','',...
    'linewidth',2);

  % RIGHT CIRCLE
  x = 320;
  fill(x+10+cx*10,y+10+cy*10,nnred,...
    'edgecolor',nndkblue,...
    'linewidth',2)
  line_2 = plot(x+10+cos([0 pi]+line_angle)*8,y+10+sin([0 pi]+line_angle)*8,...
    'color',nndkblue,...
    'CreateFcn','',...
    'linewidth',2);

  % BELT
  plot([50 330],[y y]+20,...
    'color',nndkblue,...
    'linewidth',2)
  plot([50 330],[y y],...
    'color',nndkblue,...
    'linewidth',2)
  
  % SENSOR BOX #1
  x = 130;
  fill(x+[0 40 20],y+[40 40 80],nndkblue,...
    'edgecolor',nnred)
  fill(x+[0 40 40 0],y+[14 14 8 8],nndkblue,...
    'edgecolor',nnred)
  cross = plot(x+[15 25 20 25 15],y+[50 60 55 50 60],...
    'color',nndkblue,...
    'linewidth',3,...
    'CreateFcn','');
  
  % SENSOR BOX #2
  x = 210;
  fill(x+[0 40 20],y+[40 40 80],nndkblue,...
    'edgecolor',nnred)
  fill(x+[0 40 40 0],y+[14 14 8 8],nndkblue,...
    'edgecolor',nnred)

  % EXIT BOX
  x = 320;
  fill([310 310 380 380],y+[70 50 50 70],nndkblue,...
    'edgecolor','none')
  fill(x-[10 10 50 50],y+[80 40 40 80],nndkblue,...
    'edgecolor','none')
  plot([378 x-[10 10 50 50 10 10] 378],y+[70 70 80 80 40 40 50 50],...
    'color',nnred)
  right_arrow = fill(x-30+[-5 -5 -10 0 10 5 5],y+60-[15 5 5 -15 5 5 15],nndkblue,...
    'edgecolor',nnred,...
    'CreateFcn','');
  top_ind = text(x+25,y+60,'Out',...
    'color',[0.8 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'CreateFcn','');
  bottom_ind = [0];

  % BUTTONS
  go_button = uicontrol(...
    'units','points',...
    'position',[400 150 60 20],...
    'string','Fruit',...
    'callback',[me '(''go'')']);
  uicontrol(...
    'units','points',...
    'position',[400 120 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[400 90 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[400 60 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % LOWER SEPARATION BAR
  fill([0 0 380 380],130+[0 4 4 0],nndkblue,...
    'edgecolor','none')

  % UPPER SEPARATION BAR
  fill([0 0 380 380],160+[0 4 4 0],nndkblue,...
    'edgecolor','none')
 
  % RADIO BUTTONS
  set(nndtext(20,147,'First Scanner:','left'),...
    'fontsize',12)
  rb1 = uicontrol(...
    'units','points',...
    'position',[140 139 100 20],...
    'string','Working',...
    'style','radio',...
    'value',1,...
    'callback',[me '(''working'')']);
  rb2 = uicontrol(...
    'units','points',...
    'position',[250 139 100 20],...
    'string','Not Working',...
    'style','radio',...
    'callback',[me '(''notworking'')']);

  W1 = eye(3);
  W2 = [0; 0; 0];
  set(fig,'nextplot','add')
  
  % NETWORK INPUT #1
  x1 = 83;
  y1 = 320;
  dy1 = 55;
  ddy1 = -25;
  nndtext(x1-5,y1,'Shape','right');
  p1_box1 = fill(x1+[0 20 20 0 0],y1-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  p1_text1 = nndtext(x1+10,y1,'?');
  nndtext(x1-5,y1+ddy1,'Texture','right');
  p1_box2 = fill(x1+[0 20 20 0 0],y1-10+[0 0 20 20 0]+ddy1,nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  p1_text2 = nndtext(x1+10,y1+ddy1,'?');
  nndtext(x1-5,y1+2*ddy1,'Weight','right');
  p1_box3 = fill(x1+[0 20 20 0 0],y1-10+[0 0 20 20 0]+2*ddy1,nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  p1_text3 = nndtext(x1+10,y1+2*ddy1,'?');

  % NETWORK INPUT #2
  y3 = y1-2*dy1;
  dy3 = 20;
  nndtext(x1-5,y3,'Pineapple?','right');
  p2_box = fill(x1+[0 20 20 0 0],y3-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  p2_text = nndtext(x1+10,y3,'?');

  % NEURONS
  x2 = x1+155;
  y2 = y1-dy1-12.5;
  dy2 = 67.5;
  sumdist = 50;
  sz = 15;

  plot(x2+[0 sumdist],y2+[0 0]+dy2,'linewidth',2,'color',nnred);
  plot(x2+sumdist+sz+[10 20 0 20 10],y2+[10 0 0 0 -10]+dy2,'linewidth',2,'color',nnred);
  nndtext(x2+sumdist+sz+45,y2+25+dy2,'Shape');
  nndsicon('sum',x2,y2+dy2,sz)
  nndsicon('satlins',x2+sumdist,y2+dy2,sz)
  a_box1 = fill(x2+sumdist+sz+25+[0 40 40 0 0],y2-10+[0 0 20 20 0]+dy2,nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  a_text1 = nndtext(x2+sumdist+sz+45,y2+dy2,'?');

  plot(x2+[0 sumdist],y2+[0 0],'linewidth',2,'color',nnred);
  plot(x2+sumdist+sz+[10 20 0 20 10],y2+[10 0 0 0 -10],'linewidth',2,'color',nnred);
  nndtext(x2+sumdist+sz+45,y2+25,'Texture');
  nndsicon('sum',x2,y2,sz)
  nndsicon('satlins',x2+sumdist,y2,sz)
  a_box2 = fill(x2+sumdist+sz+25+[0 40 40 0 0],y2-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  a_text2 = nndtext(x2+sumdist+sz+45,y2,'?');
  
  plot(x2+[0 sumdist],y2+[0 0]-dy2,'linewidth',2,'color',nnred);
  plot(x2+sumdist+sz+[10 20 0 20 10],y2+[10 0 0 0 -10]-dy2,'linewidth',2,'color',nnred);
  nndtext(x2+sumdist+sz+45,y2+25-dy2,'Weight');
  nndsicon('sum',x2,y2-dy2,sz)
  nndsicon('satlins',x2+sumdist,y2-dy2,sz)
  a_box3 = fill(x2+sumdist+sz+25+[0 40 40 0 0],y2-10+[0 0 20 20 0]-dy2,nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  a_text3 = nndtext(x2+sumdist+sz+45,y2-dy2,'?');

  % WEIGHTS #1
  straight = 95;
  plot([x1+20 x1+straight-50],[y1 y1],'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y1 y1 y2+dy2],'linewidth',2,'color',nnred);
  plot(x1+straight-50+[0 40 40 0 0],y1-10+[0 0 20 20 0],'color',nnred,'linewidth',2);
  nndtext(x1+straight-30,y1,'1');

  plot([x1+20 x1+straight-50],[y1 y1]+ddy1,'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y1+ddy1 y1+ddy1 y2],'linewidth',2,'color',nnred);
  plot(x1+straight-50+[0 40 40 0 0],y1-10+[0 0 20 20 0]+ddy1,'color',nnred,'linewidth',2);
  nndtext(x1+straight-30,y1+ddy1,'1');

  plot([x1+20 x1+straight-50],[y1 y1]+2*ddy1,'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y1+2*ddy1 y1+2*ddy1 y2-dy2],'linewidth',2,'color',nnred);
  plot(x1+straight-50+[0 40 40 0 0],y1-10+[0 0 20 20 0]+2*ddy1,'color',nnred,'linewidth',2);
  nndtext(x1+straight-30,y1+2*ddy1,'1');

  % WEIGHTS #2
  straight_dist = 100;
  plot([x1+20 x1+straight-50],[y3 y3-ddy1],'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y3-ddy1 y3-ddy1 y2+dy2],'linewidth',2,'color',nnred);
  W2_box1 = fill(x1+straight-50+[0 40 40 0 0],y3-10+[0 0 20 20 0]-ddy1,nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  W2_text1 = nndtext(x1+straight-30,y3-ddy1,sprintf('%5.2f',W2(1)));

  plot([x1+20 x1+straight-50],[y3 y3],'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y3 y3 y2],'linewidth',2,'color',nnred);
  W2_box2 = fill(x1+straight-50+[0 40 40 0 0],y3-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  W2_text2 = nndtext(x1+straight-30,y3,sprintf('%5.2f',W2(2)));

  plot([x1+20 x1+straight-50],[y3 y3+ddy1],'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y3+ddy1 y3+ddy1 y2-dy2],'linewidth',2,'color',nnred);
  W2_box3 = fill(x1+straight-50+[0 40 40 0 0],y3-10+[0 0 20 20 0]+ddy1,nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'CreateFcn','');
  W2_text3 = nndtext(x1+straight-30,y3+ddy1,sprintf('%5.2f',W2(3)));

  % INPUT HEADING
  temp = nndtext(x1+10,y1+25,'Inputs');

  % WEIGHT HEADING
  nndtext(x1+straight_dist-35,y1+25,'Weights');

  % SCANNER NAMES
  set(nndtext(150,122,'Shape, Texture,'),...
    'fontsize',10)
  set(nndtext(150,108,'& Weight'),...
    'fontsize',10)
  set(nndtext(230,122,''),...
    'fontsize',10)
  set(nndtext(230,108,'Pineapple?'),...
    'fontsize',10)

  % SAVE WINDOW DATA AND LOCK
  angle_ptr = uicontrol('visible','off','userdata',line_angle);
  fruit_ptr = uicontrol('visible','off','userdata',[]);

  p1_ptr = uicontrol('visible','off','userdata',[]);
  p2_ptr = uicontrol('visible','off','userdata',[]);
  a_ptr = uicontrol('visible','off','userdata',[]);
  W2_ptr = uicontrol('visible','off','userdata',W2);
  W2_ptr = uicontrol('visible','off','userdata',W2);
  mode_ptr = uicontrol('visible','off','userdata',1);

  H = nndArray({fig_axis, ...
       desc_text, ...
       line_1 line_2, ...
       fruit_ind top_ind bottom_ind, ...
       wind knock scan classify blip bloop blp tribble, ...
       angle_ptr fruit_ptr 0 0 0, ...
       left_arrow right_arrow,rb1 rb2 cross, ...
       p1_ptr p2_ptr a_ptr W2_ptr,...
       p1_box1 p1_text1 p1_box2 p1_text2 p1_box3 p1_text3, ...
       p2_box p2_text, ...
       a_box1 a_text1 a_box2 a_text2 a_box3 a_text3,...
       go_button mode_ptr, ...
       W2_box1 W2_text1 W2_box2 W2_text2 W2_box3 W2_text3});

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
    'Click [Fruit] to send',...
    'a fruit down the belt.',...
    'Click [Update] to apply',...
    'the outstar rule.',...
    '',...
    'Once the network has',...
    'seen several',...
    'pineapples with both',...
    'scanners, it will',...
    'recall their',...
    'measurements with',...
    'the first scanner off.') 
    
%==================================================================
% Respond to fruit.
%
% ME('fruit')
%==================================================================

elseif strcmp(cmd,'go') & ~isempty(fig) & (nargin == 1) & (mode == 1);

  % GET DATA
  wind = get(sounds(1),'userdata');
  knock = get(sounds(2),'userdata');
  scan = get(sounds(3),'userdata');
  classify = get(sounds(4),'userdata');
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');
  blp = get(sounds(7),'userdata');
  tribble = get(sounds(8),'userdata');
  angle = get(angle_ptr,'userdata');
  fruit = get(fruit_ptr,'userdata');
  axes(fig_axis);

  % NEW FRUIT
  nndpause(pause1)
  x = 82;
  y = 42;

  % FRUIT ID, COLOR & SHAPE
  if (rand > 0.25)
    % PINEAPPLE
    fruit_id = 4;
    fruit_x = 2+[5 2 1 0 0 1 2 5 8 9 10 10 9 8 5, 1 3 5 9 7 5];
    fruit_y = [13 12 10 8 7 5 1 0 1 5 7 8 10 12 13, 14 15 13 14 15 13];
    fruit_c = [0.8 0.8 0.4];
    p1 = [-1;-1;+1];
    p2 = 1;
  elseif (rand > 0.66)
    % BANANA
    fruit_id = 3;
    fruit_x = 4+[8 6 3 1 0 1 3 6 8 6 5 6 8];
    fruit_y = [15 15 13 11 7.5 4 2 0 0 3 7.5 12 15];
    fruit_c = nnyellow;
    p1 = [-1;+1;-1];
    p2 = 0;
  elseif (rand > 0.5)
    % ORANGE
    fruit_id = 1;
    fruit_x = [5 0 0 5 10 15 15 10];
    fruit_y = [15 10 5 0 0 5 10 15];
    fruit_c = [1 0.5 0];
    p1 = [1;-1;-1];
    p2 = 0;
  else
    % APPLE
    fruit_id = 2;
    fruit_x = [7.5 5 0 0 5 7.5 10 15 15 10];
    fruit_y = [13 15 10 5 0 2 0 5 10 15];
    fruit_c = [1 0 0];
    p1 = [+1;+1;-1];
    p2 = 0;
  end

  % FLASH FRUIT INDICATOR TWICE
  set(fig,'nextplot','add')
  nnsound(blip,Fs);
  set(fruit_indicator,...
    'color',[1 1 1])
  box = plot([10 60 60 10 10],[72 72 88 88 72],...
    'color',[1 1 1],...
    'CreateFcn','');

  nndpause(pause2)
  nnsound(bloop,Fs);
  set(fruit_indicator,...
    'color',[0.8 0.8 0])
  set(box,...
    'color',nndkblue)
  delete(box)
  nndpause(pause2)

  set(arrows(1),...
    'facecolor',nnred)
  t1 = clock;
  nnsound(wind,Fs);
  while nndpause(clock,t1) < 1, end
  nndpause(pause2)
  set(arrows(1),...
    'facecolor',nndkblue)

  set(fruit_indicator,...
    'color',[0.8 0.8 0])

  % CREATE FRUIT
  fruit = fill(x+fruit_x,y+fruit_y,fruit_c,...
    'edgecolor',fruit_c*0.5,...
    'CreateFcn','');
  set(fig,'nextplot','new')
  nnsound(knock,Fs);
  nndpause(pause2)

  % MOVE FRUIT TO SENSOR #1
  deg = pi/180;
  for dx=10:10:60
    t1 = clock;
    nnsound(blp,Fs);
    set(fruit,...
      'facecolor',nnltgray,...
      'edgecolor',nnltgray);
    set(fruit,...
      'facecolor',fruit_c,...
      'edgecolor',fruit_c*0.5,...
      'xdata',fruit_x + x + dx)
    angle = angle + 20;
    adata = [0 pi]-angle*deg;
    xdata = cos(adata)*8;
    ydata = sin(adata)*8+30;
    set(lines,'color',nnred);
    set(lines(1),...
      'xdata',xdata+50,...
      'ydata',ydata,...
      'color',nndkblue)
    set(lines(2),...
      'xdata',xdata+330,...
      'ydata',ydata,...
      'color',nndkblue)
    while nndpause(clock,t1) < 0.1, end
  end

  % SCAN FRUIT #1
  nndpause(pause2)
  working = get(rb1,'value');
  set(fig,'nextplot','add')
  if (working)
    h1 = fill([170 130 130 170],[35 35 39 39],[1 1 1],...
      'edgecolor','none',...
      'CreateFcn','');
    h2 = fill([170 130 130 170],[41 41 58 58],[1 1 1],...
      'edgecolor','none',...
      'CreateFcn','');
    set(fruit,...
     'facecolor',[1 1 1])
    t1 = clock;
    nnsound(scan,Fs);
    while nndpause(clock,t1) < 1; end
  else
    t1 = clock;
    nnsound(tribble,Fs);
    while nndpause(clock,t1) < 1, end
    p1 = [0;0;0];
  end

  t1 = clock;
  set(p1_box1,'facecolor',[1 1 1]);
  set(p1_text1,'color',nndkblue);
  set(p1_box2,'facecolor',[1 1 1]);
  set(p1_text2,'color',nndkblue);
  set(p1_box3,'facecolor',[1 1 1]);
  set(p1_text3,'color',nndkblue);
  nnsound(blip,Fs);
  while nndpause(clock,t1) < 1; end
  t1 = clock;
  set(p1_box1,'facecolor',nnltgray);
  set(p1_text1,'string',num2str(p1(1)),'color',nndkblue);
  set(p1_box2,'facecolor',nnltgray);
  set(p1_text2,'string',num2str(p1(2)),'color',nndkblue);
  set(p1_box3,'facecolor',nnltgray);
  set(p1_text3,'string',num2str(p1(3)),'color',nndkblue);
  nnsound(bloop,Fs);
  while nndpause(clock,t1) < 1; end

  if (working)
    set(h1,'facecolor',nnltgray)
    set(h2,'facecolor',nnltgray)
    delete(h1)
    delete(h2)
    set(fruit,...
      'facecolor',fruit_c)
    set(fig,'nextplot','new')
  end
  nndpause(pause2)

  % MOVE FRUIT TO SENSOR #2
  deg = pi/180;
  for dx=70:10:140
    t1 = clock;
    nnsound(blp,Fs);
    set(fruit,...
      'facecolor',nnltgray,...
      'edgecolor',nnltgray);
    set(fruit,...
      'facecolor',fruit_c,...
      'edgecolor',fruit_c*0.5,...
      'xdata',fruit_x + x + dx)
    angle = angle + 20;
    adata = [0 pi]-angle*deg;
    xdata = cos(adata)*8;
    ydata = sin(adata)*8+30;
    set(lines,'color',nnred);
    set(lines(1),...
      'xdata',xdata+50,...
      'ydata',ydata,...
      'color',nndkblue)
    set(lines(2),...
      'xdata',xdata+330,...
      'ydata',ydata,...
      'color',nndkblue)
    while nndpause(clock,t1) < 0.1, end
  end

  % SCAN FRUIT #2
  nndpause(pause2)
  set(fig,'nextplot','add')
  h1 = fill(80+[170 130 130 170],[35 35 39 39],[1 1 1],...
    'edgecolor','none',...
    'CreateFcn','');
  h2 = fill(80+[170 130 130 170],[41 41 58 58],[1 1 1],...
    'edgecolor','none',...
    'CreateFcn','');
  set(fruit,...
   'facecolor',[1 1 1])

  t1 = clock;
  nnsound(scan,Fs);
  while nndpause(clock,t1) < 1, end

  t1 = clock;
  set(p2_box,'facecolor',[1 1 1]);
  set(p2_text,'color',nndkblue);
  nnsound(blip,Fs);
  while nndpause(clock,t1) < 1; end
  t1 = clock;
  set(p2_box,'facecolor',nnltgray);
  set(p2_text,'string',num2str(p2),'color',nndkblue);
  nnsound(bloop,Fs);
  while nndpause(clock,t1) < 1; end

  set(h1,'facecolor',nnltgray)
  set(h2,'facecolor',nnltgray)
  delete(h1)
  delete(h2)
  set(fruit,...
    'facecolor',fruit_c)
  set(fig,'nextplot','new')
  nndpause(pause2)

  % CLASSIFY FRUIT
  W2 = get(W2_ptr,'userdata');
  n = p1+W2*p2;
  a = (~((n < -1) | (n > 1))).*n + (n > 1) - (n < -1);

  t1 = clock;
  set(a_box1,'facecolor',[1 1 1]);
  set(a_text1,'color',nndkblue);
  set(a_box2,'facecolor',[1 1 1]);
  set(a_text2,'color',nndkblue);
  set(a_box3,'facecolor',[1 1 1]);
  set(a_text3,'color',nndkblue);
  nnsound(blip,Fs);
  while nndpause(clock,t1) < 1; end
  t1 = clock;
  set(a_box1,'facecolor',nnltgray);
  set(a_text1,'string',sprintf('%5.2f',a(1)),'color',nndkblue);
  set(a_box2,'facecolor',nnltgray);
  set(a_text2,'string',sprintf('%5.2f',a(2)),'color',nndkblue);
  set(a_box3,'facecolor',nnltgray);
  set(a_text3,'string',sprintf('%5.2f',a(3)),'color',nndkblue);
  nnsound(bloop,Fs);
  while nndpause(clock,t1) < 1; end

  % MOVE DATA FROM NETWORK TO EXIT
  indicator = top_indicator;
  box_x = 73;
  set(indicator,...
    'color',[1 1 1])
  axes(fig_axis)
  set(fig,'nextplot','add')
  box = plot([0 62 62 0 0]+314,[0 0 15 15 0]+box_x,...
    'color',[1 1 1],...
    'CreateFcn','');

  nndpause(pause2);
  nnsound(bloop,Fs);

  % MOVE FRUIT TO EXIT
  for dx=150:10:200
    t1 = clock;
    nnsound(blp,Fs);
    set(fruit, ...
      'facecolor',nnltgray, ...
      'edgecolor',nnltgray);
    set(fruit, ...
      'facecolor',fruit_c, ...
      'edgecolor',fruit_c*0.5, ...
      'xdata',fruit_x + x + dx)
    angle = angle + 20;
    adata = [0 pi]-angle*deg;
    xdata = cos(adata)*8;
    ydata = sin(adata)*8+30;
    set(lines,'color',nnred);
    set(lines(1),...
      'xdata',xdata+50,...
      'ydata',ydata,...
      'color',nndkblue)
    set(lines(2),...
      'xdata',xdata+330,...
      'ydata',ydata,...
      'color',nndkblue)
    while nndpause(clock,t1) < 0.1, end
  end

  % REMOVE FRUIT
  nndpause(pause1)
  nnsound(blip,Fs);
  set(fruit,...
    'facecolor',nnltgray,...
    'edgecolor',nnltgray);
  delete(fruit)
  set(arrows(2),...
    'facecolor',nnred)
  nnsound(wind,Fs);
  set(arrows(2),...
    'facecolor',nndkblue)

  % UNLIGHT APPROPRIATE INDICATOR
  nndpause(pause1)
  nnsound(bloop,Fs);
  set(indicator,...
    'color',[0.8 0.8 0])
  set(box,...
    'color',nndkblue)
  delete(box)
  set(fig,'nextplot','new')

  % CHANGE GO BUTTON
  set(go_button,'string','Update');
  set(mode_ptr,'userdata',2);

  % SAVE DATA
  set(angle_ptr,'userdata',angle);
  set(fruit_ptr,'userdata',fruit);
  set(p1_ptr,'userdata',p1);
  set(p2_ptr,'userdata',p2);
  set(a_ptr,'userdata',a);  

%==================================================================
% Respond to fruit.
%
% ME('update')
%==================================================================

elseif strcmp(cmd,'go') & ~isempty(fig) & (nargin == 1) & (mode == 2);

  % GET DATA
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');
  p2 = get(p2_ptr,'userdata');
  W2 = get(W2_ptr,'userdata');
  a = get(a_ptr,'userdata');

  % UPDATE WEIGHT
  W2 = W2 + (0.2*ones(3,1)*p2').*(a-W2); % learnos(W2,p2,a,0.2);

  t1 = clock;
  set(W2_box1,'facecolor',[1 1 1]);
  set(W2_text1,'color',nndkblue);
  set(W2_box2,'facecolor',[1 1 1]);
  set(W2_text2,'color',nndkblue);
  set(W2_box3,'facecolor',[1 1 1]);
  set(W2_text3,'color',nndkblue);
  nnsound(blip,Fs);
  while nndpause(clock,t1) < 1; end
  t1 = clock;
  set(W2_box1,'facecolor',nnltgray);
  set(W2_text1,'string',sprintf('%5.2f',W2(1)),'color',nndkblue);
  set(W2_box2,'facecolor',nnltgray);
  set(W2_text2,'string',sprintf('%5.2f',W2(2)),'color',nndkblue);
  set(W2_box3,'facecolor',nnltgray);
  set(W2_text3,'string',sprintf('%5.2f',W2(3)),'color',nndkblue);
  nnsound(bloop,Fs);
  while nndpause(clock,t1) < 1; end

  % CLEAR INPUT AND OUTPUT
  set(p1_text1,'color',nnltgray);
  set(p1_text2,'color',nnltgray);
  set(p1_text3,'color',nnltgray);
  set(p2_text,'color',nnltgray);
  set(a_text1,'color',nnltgray);
  set(a_text2,'color',nnltgray);
  set(a_text3,'color',nnltgray);
  set(p1_text1,'color',nndkblue,'string','?');
  set(p1_text2,'color',nndkblue,'string','?');
  set(p1_text3,'color',nndkblue,'string','?');
  set(p2_text,'color',nndkblue,'string','?');
  set(a_text1,'color',nndkblue,'string','?');
  set(a_text2,'color',nndkblue,'string','?');
  set(a_text3,'color',nndkblue,'string','?');
  
  % CHANGE GO BUTTON
  set(go_button,'string','Fruit');
  set(mode_ptr,'userdata',1);

  % SAVE DATA
  set(W2_ptr,'userdata',W2);

%==================================================================
% Clear weights.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & ~isempty(fig) & (nargin == 1)
  
  % GET DATA
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');

  % CLEAR WEIGHT
  W2 = [0; 0; 0];

  t1 = clock;
  set(W2_box1,'facecolor',[1 1 1]);
  set(W2_text1,'color',nndkblue);
  set(W2_box2,'facecolor',[1 1 1]);
  set(W2_text2,'color',nndkblue);
  set(W2_box3,'facecolor',[1 1 1]);
  set(W2_text3,'color',nndkblue);
  nnsound(blip,Fs);
  while nndpause(clock,t1) < 1; end
  t1 = clock;
  set(W2_box1,'facecolor',nnltgray);
  set(W2_text1,'string',sprintf('%5.2f',W2(1)),'color',nndkblue);
  set(W2_box2,'facecolor',nnltgray);
  set(W2_text2,'string',sprintf('%5.2f',W2(2)),'color',nndkblue);
  set(W2_box3,'facecolor',nnltgray);
  set(W2_text3,'string',sprintf('%5.2f',W2(3)),'color',nndkblue);
  nnsound(bloop,Fs);
  while nndpause(clock,t1) < 1; end

  % CLEAR INPUT AND OUTPUT
  set(p1_text1,'color',nnltgray);
  set(p1_text2,'color',nnltgray);
  set(p1_text3,'color',nnltgray);
  set(p2_text,'color',nnltgray);
  set(p2_text,'color',nnltgray);
  set(a_text1,'color',nnltgray);
  set(a_text2,'color',nnltgray);
  set(a_text3,'color',nnltgray);
  set(p1_text1,'color',nndkblue,'string','?');
  set(p1_text2,'color',nndkblue,'string','?');
  set(p1_text3,'color',nndkblue,'string','?');
  set(p2_text,'color',nndkblue,'string','?');
  set(a_text1,'color',nndkblue,'string','?');
  set(a_text2,'color',nndkblue,'string','?');
  set(a_text3,'color',nndkblue,'string','?');
  
  % CHANGE GO BUTTON 
  set(go_button,'string','Fruit');
  set(mode_ptr,'userdata',1);

  % SAVE DATA
  set(W2_ptr,'userdata',W2);

%==================================================================
% "Working" radio button.
%
% ME('working')
%==================================================================

elseif strcmp(cmd,'working') & ~isempty(fig)

  set(rb1,'value',1);
  set(rb2,'value',0);
  set(cross,'color',nndkblue);

%==================================================================
% "Not Working" radio button.
%
% ME('working')
%==================================================================

elseif strcmp(cmd,'notworking') & ~isempty(fig)

  set(rb1,'value',0);
  set(rb2,'value',1);
  set(cross,'color',nnred);
end
