function result = uint8Array2dec(array)
result = '';
for idx = 1:length(array)
    number = stuffZeros(dec2bin(array(idx)));
    result = [number, result];%#ok
end
result = bin2dec(result);
end

function binary = stuffZeros(number)

while length(number)~=8
    number = ['0',number];%#ok
end
binary = number;
end