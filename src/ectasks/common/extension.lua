-- Represents a extension module for lua.

-- Return true if the value is a number and false otherwise.
function isnumber(v)
   return type(v) == "number"
end

-- Return true if the value is a integer and false otherwise.
function isinteger(v)
   return math.type(v) == "integer"
end

-- Return true if the value is a float and false otherwise.
function isfloat(v)
   return math.type(v) == "float"
end

-- Return true if the value is a string and false otherwise.
function isstring(v)
   return type(v) == "string"
end

-- Return true if the value is nil and false otherwise.
function isnil(v)
   return type(v) == "nil"
end

-- Return true if the value is a table and false otherwise.
function istable(v)
   return type(v) == "table"
end

-- Return true if the value is a function and false otherwise.
function isfunction(v)
   return type(v) == "function"
end

-- Removes any leading and trailing whitespace characters.
function string.trim(s)
   return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

-- Removes any leading whitespace characters.
function string.trimstart(s)
   return string.gsub(s, "^%s+", "")
end

-- Removes any trailing whitespace characters.
function string.trimend(s)
   return string.gsub(s, "%s+$", "")
end
