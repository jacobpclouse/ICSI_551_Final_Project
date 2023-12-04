function robotHOME(comPORT)


% set up robot

moveFILE = 'Arm-Move-2.rxe';
homeFILE = 'Arm-Home.rxe';
lego = legoNXT(comPORT);

if lego.doesFileExist(moveFILE)
    disp('Robot Ready');
else
    disp('Problem with robot!');
end

lego.startProgram(homeFILE);
