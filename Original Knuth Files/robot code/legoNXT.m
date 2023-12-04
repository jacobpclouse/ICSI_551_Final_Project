% Modified by Rotem Guttman: 4 June 2009

function h = legoNXT(comport)

disp('Lego go!')

h = [];
global hrealterm;
realtermstart(comport);  %START realterm for serial communications
logid = fopen('c:\temp\matlab_data.dat');


%enumarated motor types
h.MOTOR_A = 0;
h.MOTOR_B = 1;
h.MOTOR_C = 2;

h.playTone = @playTone; %TESTED, WORKING
h.sendData = @sendData; %TESTED, WORKING

h.waitForResponse = @waitForResponse;
h.writeFile = @writeFile;
h.readFile = @readFile;
h.startProgram = @startProgram; %TESTED, WORKING

h.doesFileExist = @doesFileExist;
h.deleteFile = @deleteFile;
h.findFile = @findFile;


%--------------------- My Code ----------


    function result = startProgram(fileName)
        result = -1;
        sendData([0 0 char2num(fileName,20)]);

        response = h.waitForResponse();
        status = response(5);

        if status == 0
            % Program is running
            result = 1;
        end

    end

    function result = doesFileExist(fileName)
        result = false;

        % Find first
        sendData([1 hex2dec('86') char2num(fileName,20)]);

        % Read response from log file into response
        response = h.waitForResponse();

        status = response(5);
        fileHandle = response(6);
        foundFileName = num2char(response(7:26));

        if strcmp(fileName,foundFileName(1:length(fileName)))
            result = true;
            %close command
            closeFile(fileHandle);
        else
            if strcmpi(deblank(foundFileName),'file not found') || status == hex2dec('87')
                % do not close
            else
                %close command
                closeFile(fileHandle);
            end
        end

    end

    function closeFile(fileHandle)
        sendData([1 hex2dec('84') fileHandle]);

        response = h.waitForResponse();
    end

    function deleteFile(fileName)
        sendData([1 hex2dec('85') char2num(fileName,20)])

        response = h.waitForResponse();
    end


    function result = readFile(fileName)
        dumpPacket(); %% clear log file and reset global var.
        result = -1;

        % Open the file for reading
        sendData([1 hex2dec('80') char2num(fileName,20)]);

        response = h.waitForResponse();

        status = response(5);
        fileHandle = response(6);
        sizeOfFile = uint8Array2dec(response(7:10));

        if status == 0
            % The file is open, read the data

            sendData([1 hex2dec('82') fileHandle dec2uint8Array(sizeOfFile,2)]);

            response = h.waitForResponse();

            status = response(5);
            fileHandle = response(6);
            sizeOfDataRead = uint8Array2dec(response(7:8));
            data = response(9:end);

            if status == 0
                % The file is read, now close it

                sendData([1 hex2dec('84') fileHandle]);

                response = h.waitForResponse();

                status = response(5);

                if status == 0
                    result = data;
                end

            end
        end

    end


    function result = writeFile(fileName, data)
        dumpPacket();
        result = -1;

        if doesFileExist(fileName)
            % delete file
            deleteFile(fileName);
        end

        sizeOfFile = length(data);
        % Open file for writing
        sendData([1 hex2dec('81') char2num(fileName,20) dec2uint8Array(sizeOfFile,4)]);

        response = h.waitForResponse();

        status = response(5);
        fileHandle = response(6);

        if status == 0
            % File is open, write to it
            sendData([1 hex2dec('83') fileHandle reshape(data,1,length(data))]);

            response = h.waitForResponse();

            status = response(5);
            fileHandle = response(6);
            dataWritten = uint8Array2dec(response(7:8));

            if status == 0
                % Now close the file
                sendData([1 hex2dec('84') fileHandle]);

                response = h.waitForResponse();

                status = response(5);
                if status == 0
                    result = dataWritten;
                end

            end
        end
    end

    function dumpPacket() % RECODE FOR LOG FILE
       garbagedump = fread(logid);
       %This will move the next byte to be read to the end of the file
       %Could use Fseek here for faster work but would rather be able to
       %debug and view garbage discarded in this manner.
    end

    function result = waitForResponse() % RECODE FOR LOG FILE
        idx = 0;
        timeoutLength = 30; % Seconds
        pauseLength = .1;

        a = 'OK';
        %disp(a)
        % Loop until we know how long the packet is
        while (feof(logid) == 0) && (idx < timeoutLength)
            idx = idx+1;
            pause(pauseLength);
        end
        %disp(['idx = ' num2str(idx)]);
            pause(1);
            result = fread(logid);
            %disp(result)
            %status = result(5);
            %disp(status)
            %lengthOfPacket = uint8Array2dec(result(1:2));
            %disp(lengthOfPacket);  
            
            disp(result) % debugging, comment out later.
    end


    function resultString = fileErrorCodeLookup(errorCodeNumer)
        switch dec2hex(errorCodeNumer)
            case '81'
                resultString = 'No more handles';
            case '8F'
                resultString = 'File Exists';
            case '87'
                resultString = 'File Not Found';
            otherwise
                resultString = 'Uknown error';
        end
    end

    function [] = playTone(frequency,duration)
        %global hrealterm
        frequency = dec2uint8Array(frequency,2);
        duration = dec2uint8Array(duration,2);
        tosend=[0 3 frequency duration];
        sendData(tosend)
    end

    function [] = sendData(data)
        %global hrealterm
        messlength = length(data);
        messlength = dec2uint8Array(messlength,2);
        data = [messlength data];
        for i=1:length(data)
            invoke(hrealterm,'PutChar',char(data(i)));
        end
    end

end
