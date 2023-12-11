%% Interact with EV3 Brick Peripherals, Read Sensor Values, and Control Motors
%
% This example shows you how to interact with the EV3 brick peripherals,
% read a sensor value, and control a motor.
 
% Copyright 2014 The MathWorks, Inc.
 
 
%% Introduction
%
% This example shows you how to use MATLAB(R) command to:
%
% * Interact with the EV3 brick peripherals: display text on the LCD; play
% a tone on the speaker; read the button status; control the color and state of the status light.
% * Read the touch sensor value.
% * Control the speed and direction of a motor.

 
%% Prerequisites
%
% Create a connection to the EV3 brick called *|mylego|*, as described in
% <docid:legomindstormsev3io_ref.example-ev3io_gettingstarted Getting
% Started with MATLAB Support Package for LEGO MINDSTORMS EV3 Hardware> example. 
 
%% Required Hardware
% 
% This example requires additional hardware:
%
% * EV3 Touch Sensor 
% * EV3 Motor

 
%% Task 1 - Interact with Brick Peripherals
% Use *|mylego|* to interact with the brick peripherals: LCD, speaker, buttons, and status light.
%
% *1. Clear the LCD, and then write text on row 2, column 3.*
%
%   clearLCD(mylego)
%
%  writeLCD(mylego,'Hello, LEGO!',2,3)
%
%
% *2. Play a 500 Hz tone on the speaker for 3 seconds, with the volume
% level set to 20.*
%
%   playTone(mylego,500,3,20)
%
%
% *3. Read the status of the up button. If the button is pressed, the
% status is 1. Otherwise, the status is 0.*
%
%   readButton(mylego,'up')
%
%
% *4. Illuminate the status light with a red LED, and then turn it off.*
%
%   writeStatusLight(mylego,'red')
%
%   writeStatusLight(mylego,'off')
%
%
% *For more information, enter:* 
%
%   help legoev3
%
%
%% Task 2 - Read a Sensor Value
% To interact with sensors that are connected to the input ports on the EV3 brick, create a handle for the sensor. Then, use this handle to perform operations such as reading sensor values. 
%
% *1. Plug a touch sensor into port #1 on the EV3 brick, and create a
% handle for it.*
%
%   mytouch = touchSensor(mylego,1)
%
% *2. Read the value of the touch sensor - pressed (1) and not pressed (0)*
%
%   readTouch(mytouch)
%
% *For more information, enter:*
%
%   help touchSensor
%
%
%% Task 3 - Control the Speed and Direction of a Motor
% To interact with motors that are connected to the output ports on the EV3 brick, create a handle for the motor. Use the Speed property to set the speed and direction of the motor. Then, use the handle to start and stop the motor.
%
% *1. Plug a motor into port #A on the EV3 brick, and create a handle for it.*
%
%   mymotor = motor(mylego,'A')
%
% *2. Set the motor speed by assigning a value to the |Speed| property.*
%
%   mymotor.Speed = 20
%
% *3. Start the motor.*
%
%   start(mymotor)
%
% *4. Change the motor speed and reverse its direction.*
%
%   mymotor.Speed = -10
%
% *5. Stop the motor.*
%
%   stop(mymotor)
%
% *For more information, enter:*
%
%   help motor
% 
%
%% Task 4 - Clear Objects
%  
% To discard the mylego, mymotor, and mytouch object handles, use the clear function.
%
%   clear

 
%% Summary
% 
% This example showed you how to:
%
% * Interact with EV3 brick peripherals - LCD, speaker, buttons and status light.
% * Read the status of a touch sensor.
% * Control the speed and direction of a motor.

