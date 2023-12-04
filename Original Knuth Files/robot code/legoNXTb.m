function h = legoNXT(comport)
h.serialobj = instrfind('Port',comport);
if isempty(h.serialobj)
    h.serialobj = serial(comport);
end

if ~strcmpi(h.serialobj.Status,'open')
    fopen(h.serialobj);
end

%enumarated motor types
h.MOTOR_A = 0;
h.MOTOR_B = 1;
h.MOTOR_C = 2;

h.disconnect = @disconnect;
h.playTone = @playTone;
h.getBatteryLevel = @getBatteryLevel;
h.sendMessage = @sendMessage;
h.waitForResponse = @waitForResponse;
h.addMotor = @addMotor;

    function motorobj = addMotor(motorport)       
        motorobj = legonxtMotor(h,motorport);
    end

    function disconnect()
        if ~isempty(h.serialobj)
            fclose(h.serialobj);
        end
    end

    function playTone(frequency,duration)
        frequency = dec2uint8Array(frequency,2);
        duration = dec2uint8Array(duration,2);
        sendMessage([0 3 frequency duration]); %nested function

        resultmessage = h.waitForResponse();
        if ~isequal(resultmessage,[3 0 2 3 0])
            error('Error while playing tone');
        end
    end

    function sendMessage(message)
        if strcmpi(h.serialobj.Status,'open')
            messlength = length(message);
            messlength = dec2uint8Array(messlength,2);
            fwrite(h.serialobj,uint8([messlength message]));
        else
            error(['Serial Connection on ',h.serialobj.Port,' is not open']);
        end
    end

    function result = waitForResponse()
        idx = 0;
        while h.serialobj.BytesAvailable == 0 && idx < 100
            idx = idx+1;
            pause(.01);
        end
        if h.serialobj.BytesAvailable ~=0
            result = fread(h.serialobj,h.serialobj.BytesAvailable);
            packlength = result(1:2);
            if uint8Array2dec(packlength)~= length(result(3:end))
                error('Packet lost');
            end
        else
            error('Device timed out');
        end
        result = result';
    end

    function result = getBatteryLevel()
        sendMessage([00 11]);
        retpack = waitForResponse();
        batvoltage = retpack(6:end);
        result = uint8Array2dec(batvoltage);
        result = result/1000;
    end

end