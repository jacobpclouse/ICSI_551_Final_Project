function robotMOVE(nextX, nextY, nextZ)

currentROTC = 0;

% set up robot

moveFILE = 'Arm-Move-3.rxe';
homeFILE = 'Arm-Home.rxe';
lego = legoNXT('COM14');

if lego.doesFileExist(moveFILE)
    disp('Robot Ready');
else
    disp('Problem with robot!');
end



% convert to motor rotations
[rotA, rotB, rotC] = cart2rot(nextX,nextY,nextZ);
deltaROTC = rotC - currentROTC;
disp(['X = ' num2str(nextX) '  Y = ' num2str(nextY) '  Z = ' num2str(nextZ)]);
disp([num2str(deltaROTC) '  ' num2str(rotB) '  ' num2str(rotA)])
currentROTC = rotC;
dirC = deltaROTC>0;  % dirC = 1 if to CCW (from above) or 0 if CW

% encode into message to robot
ending = char([13 10]);
message = double([num2str(dirC) ending num2str(abs(deltaROTC)) ending num2str(rotB) ending num2str(rotA) ending ]);

% send message
success = 0;
while success == 0
    lego.deleteFile('pos.txt');
    lego.deleteFile('meas.txt');
    result = lego.writeFile('pos.txt', message);
    if result < 0
        disp('Problem sending message')
    else
        success = 1;
    end
end

% initiate robot
lego.startProgram(moveFILE);


