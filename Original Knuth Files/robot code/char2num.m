function value = char2num(character,varargin)
minLength = 0;
if ~isempty(varargin)
   minLength = varargin{1};  
end
value = [];
for idx = 1:length(character)
charfound = 0;
counter = 1;
while ~charfound && counter<255
    if strcmp(char(counter),character(idx))
       charfound = 1;
       value(idx) = counter;
    else
        counter = counter + 1;
    end
end
end

while length(value) < minLength
    value(end+1) = 0;
end