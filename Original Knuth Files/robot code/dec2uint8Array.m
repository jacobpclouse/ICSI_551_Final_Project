function result = dec2uint8Array(number, pairs)
number = dec2bin(number);

result = zeros(1,pairs);
pairidx = 1;
while ~isempty(number) && pairidx <= length(result)
    if length(number)>=8
        result(pairidx) = bin2dec(number(end-7:end));
        number = number(1:end-8);
    else
        result(pairidx) = bin2dec(number);
        number = '';
    end
    pairidx = pairidx + 1;
end
end