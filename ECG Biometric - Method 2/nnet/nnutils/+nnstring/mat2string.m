function s = mat2string(m)

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $  $Date: 2013/04/25 09:44:05 $

[rows,cols] = size(m);
s = '[';
for row=1:rows
  if (row ~= 1)
    s = [s sprintf(';\n ')];
  end
  for col=1:cols
    if (col ~= 1)
      s = [s ' '];
    end
    s = [s num2str(m(row,col))];
  end
end
s = [s ']'];
