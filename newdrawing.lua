local setrender = setrenderproperty or function(drawing, index, value) drawing[index] = value end;
local getrender = getrenderproperty or function(drawing, index) return drawing[index] end;
local drawing_new = Drawing.new;
getrenv().Drawing.new = function(object)
     local drawing = drawing_new(object);
     return setmetatable({}, {
          __index = function(self, index)
               return getrender(drawing, index);
          end,
          __newindex = function(self, index, value)
               setrender(drawing, index, value);
          end,
     });
end
