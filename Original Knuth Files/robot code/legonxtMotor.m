function h = legonxtMotor(hparent,portused)
hParent = hparent;
port = portused;

%default values
powerset = 100;
%Enumeration for Mode
h.MOTORON = 'MOTORON';
h.BRAKE = 'BRAKE';
h.REGULATED = 'REGULATED';

%Enumerations for Regulation Mode
h.REGULATION_MODE_IDLE = 'REGULATION_MODE_IDLE';
h.REGULATION_MODE_MOTOR_SPEED = 'REGULATION_MODE_MOTOR_SPEED';
h.REGULATION_MODE_MOTOR_SYNC = 'REGULATION_MODE_MOTOR_SPEED';

%Enumerations for RunState
h.MOTOR_RUN_STATE_IDLE = 'MOTOR_RUN_STATE_IDLE';
h.MOTOR_RUN_STATE_RAMPUP = 'MOTOR_RUN_STATE_RAMPUP';
h.MOTOR_RUN_STATE_RUNNING = 'MOTOR_RUN_STATE_RUNNING';
h.MOTOR_RUN_STATE_RAMPDOWN = 'MOTOR_RUN_STATE_RAMPDOWN';

% pass back the function handles
h.getOutputState = @getOutputState;
h.setOutputState = @setOutputState;
h.moveMotor = @moveMotor;

    function moveMotor(power,movedistance)
        
        if power<0
           powersetpoint = abs(power) + 126;
        else
           powersetpoint = min(power,126);
        end
        
        setOutputState(powersetpoint,h.MOTORON, h.REGULATION_MODE_MOTOR_SPEED,1,...
            h.MOTOR_RUN_STATE_RUNNING,movedistance);
        
    end

    function setOutputState(powersetpoint,modebyte,regulationmode,...
            turnratio,runstate,tacholimit)
        hParent.sendMessage([128 04 ...
            dec2uint8Array(port,1)...
            dec2uint8Array(powersetpoint,1)...
            dec2uint8Array(getEnumeratedValue(modebyte),1)...
            dec2uint8Array(getEnumeratedValue(regulationmode),1)...
            dec2uint8Array(turnratio,1)...
            dec2uint8Array(getEnumeratedValue(runstate),1)...
            dec2uint8Array(tacholimit,5)]);
%         resultmessage = hParent.waitForResponse();
%         if ~isequal(resultmessage,[3 0 2 4 0])
%             error('Error while setting outputstate');
%         end
    end

    function retobj = getOutputState()
        hParent.sendMessage([00 06 port]);
        retpack = hParent.waitForResponse();
        retobj = [];
        retobj.Port = retpack(4);
        retobj.PowerSet = retpack(5);
        retobj.Mode = retpack(6);
        retobj.RegulationMode = retpack(7);
        retobj.TurnRatio = retpack(8);
        retobj.RunState = retpack(9);
        retobj.TachoLimit = uint8Array2dec(retpack(10:13));
        retobj.TachCount = uint8Array2dec(retpack(14:17));
        retobj.BlockTachoCount = uint8Array2dec(retpack(18:21));
        retobj.RotationCount = uint8Array2dec(retpack(22:25));
    end

    function value = getEnumeratedValue(enum)
        value = [];
        switch enum
            case h.MOTORON
                value = hex2dec('01');
            case h.BRAKE
                value = hex2dec('02');
            case h.REGULATED
                value = hex2dec('04');
            case h.REGULATION_MODE_IDLE
                value = hex2dec('00');
            case h.REGULATION_MODE_MOTOR_SPEED
                value = hex2dec('01');
            case h.REGULATION_MODE_MOTOR_SYNC
                value = hex2dec('02');
            case h.MOTOR_RUN_STATE_IDLE
                value = hex2dec('00');
            case h.MOTOR_RUN_STATE_RAMPUP
                value = hex2dec('10');
            case h.MOTOR_RUN_STATE_RUNNING
                value = hex2dec('20');
            case h.MOTOR_RUN_STATE_RAMPDOWN
                value = hex2dec('40');
        end
    end
end
