function resultString = num2char(asciizstring)
resultString = '';

for idx = 1:length(asciizstring)
   resultString(idx) = char(asciizstring(idx));%#ok 
end
end