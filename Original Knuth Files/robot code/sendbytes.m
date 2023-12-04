function [] = sendbytes(sendstring);
  % Converts String of HEX Numbers in 0x00 form to Characters and sends
  % them out via Realterm
  % NOTE: If you don't call realtermstart() first, sorrow and unrest will reign. 
  % Also, it won't work.
  
  global hrealterm;   % activex handle for realterm RS-232 terminal program

  byteparse=findstr(sendstring,'0x');  %finds the hex notation start characters for the string
  outstring='';
  for i=1:length(byteparse);
      bytestring=sendstring(byteparse(i)+2:byteparse(i)+3);
      outchar=char(hex2dec(bytestring));
      outstring=[outstring, outchar];
      invoke(hrealterm,'PutChar',outchar); % send the characters byte by byte
  end;
  %disp(['Bytes Sent: ', sendstring]);