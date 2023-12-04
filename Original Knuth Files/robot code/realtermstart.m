function [] = realtermstart(portnumSTRING);
  % setup real term for active x control of serial port,
  global hrealterm;   % activex handle for realterm RS-232 terminal program

  hrealterm=actxserver('realterm.realtermintf'); % start Realterm as a server
  hrealterm.baud=9600;
  hrealterm.caption='Knuth Cyberphysics Laboratory Realterm Server';
  hrealterm.windowstate=0; %minimized
  hrealterm.Port=num2str(portnumSTRING); %input as X where X is the number.(No 'COM')
  hrealterm.PortOpen=1; %open the comm port
  hrealterm.HalfDuplex=1;
  hrealterm.FlowControl=0;
  hrealterm.LinefeedIsNewline=0;
  hrealterm.DisplayAs=2;
  hrealterm.CaptureFile='c:\temp\matlab_data.dat';
  invoke(hrealterm,'startcapture'); %start capture (if error 103, you need to create the folder first!)
  % Note to self, To stop capture use: invoke(hrealterm,'stopcapture');
  % Note to any grad student editing my code:
  % Read: http://realterm.sourceforge.net/realterm_from_matlab.html
  
  