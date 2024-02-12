require("common.extension")
local sqlite = require("sqlite")

local dbtasks = {}

dbtasks.SORT = {
  SequenceASC = "sequence ASC",
  SequenceDESC = "sequence DESC",
  SubjectASC = "subject ASC",
  SubjectDESC = "subject DESC",
  StatusASC = "status ASC",
  StatusDESC = "status DESC"
}

dbtasks.SHOW = {
  AllTasks = "status < 2",
  ActiveTasks = "status = 0",
  CompletedTasks = "status = 1"
}

local Database = Object(sqlite.Database)

function Database:constructor(...)
  super(self).constructor(self, ...)

  self:exec([[CREATE TABLE IF NOT EXISTS "tbl_tasks" (
    "sequence"	INTEGER NOT NULL,
    "subject"	TEXT NOT NULL,
    "status" INTEGER DEFAULT 0,
    PRIMARY KEY("sequence" AUTOINCREMENT)
  );]])

  self:exec([[CREATE TABLE IF NOT EXISTS "tbl_file" (
    "number"	INTEGER NOT NULL,
    "name"	TEXT,
    "path"	TEXT
  );]])

  self:exec("INSERT INTO tbl_file (number) SELECT 99 WHERE NOT EXISTS (SELECT 1 FROM tbl_file);")
end

function create()
  local t = Database(":memory:")
  return t
end

function Database:save(path)
  if not isstring(path) then return end
  if path:trim() == "" then return end
  self:exec("VACUUM main INTO '" .. path .. "';")
end

function Database:countall()
  local result = self:exec("SELECT COUNT(*) FROM tbl_tasks;")
  return result["COUNT(*)"]
end

function Database:countactive()
  local result = self:exec("SELECT COUNT(*) FROM tbl_tasks WHERE status = 0;")
  return result["COUNT(*)"]
end

function Database:countcompleted()
  local result = self:exec("SELECT COUNT(*) FROM tbl_tasks WHERE status = 1;")
  return result["COUNT(*)"]
end

function Database:countfiltered(show, filter)
  local query = "SELECT COUNT(*) FROM tbl_tasks WHERE " .. show

  if not isnil(filter) then
    query = query .. " AND subject LIKE '" .. filter .. "'"
  end

  local result = self:exec(query)
  return result["COUNT(*)"]
end

function Database:insert(subject)
  if not isstring(subject) then return end
  if subject:trim() == "" then return end

  local query = string.format("INSERT INTO tbl_tasks (subject) VALUES('%s');'", subject)
  self:exec(query)
end

function Database:update(sequence, subject, status)
  if not isinteger(sequence) then return end
  if sequence < 0 then return end

  if not isstring(subject) then return end
  if subject:trim() == "" then return end

  if not isinteger(status) then return end
  if status ~= 0 and status ~= 1 then return end

  local query = string.format("UPDATE tbl_tasks SET subject = '%s', status = %d WHERE sequence = %d;", subject, status,
    sequence)
  self:exec(query)
end

function Database:updatesubject(sequence, subject)
  if not isinteger(sequence) then return end
  if sequence < 0 then return end

  if not isstring(subject) then return end
  if subject:trim() == "" then return end

  local query = string.format("UPDATE tbl_tasks SET subject = '%s' WHERE sequence = %d;", subject, sequence)
  self:exec(query)
end

function Database:updatestatus(sequence, status)
  if not isinteger(sequence) then return end
  if sequence < 0 then return end

  status = (status and 1) or 0

  local query = string.format("UPDATE tbl_tasks SET status = %d WHERE sequence = %d;", status, sequence)
  self:exec(query)
end

function Database:delete(sequence)
  if not isinteger(sequence) then return end
  if sequence < 0 then return end

  local query = string.format("DELETE FROM tbl_tasks WHERE sequence = %d;", sequence)
  self:exec(query)
end

function Database:select(offset, sort, show, filter)
  --if not isinteger(offset) then return end
  --if offset <= 0 then return end

  if not isstring(sort) then return end
  if sort:trim() == "" then return end

  if not isstring(show) then return end
  if show:trim() == "" then return end

  local query = string.format("SELECT * FROM tbl_tasks WHERE %s ", show)

  if not isnil(filter) then
    query = query .. string.format("AND subject LIKE '%s' ", filter)
  end

  query = query .. string.format("ORDER BY %s LIMIT 12 OFFSET %s;", sort, offset)

  return self:query(query)
end

function Database:updatefile(name, path)
  if not isstring(name) then return end
  if name:trim() == "" then return end

  if not isstring(path) then return end
  if path:trim() == "" then return end

  local query = string.format("UPDATE tbl_file SET name = '%s', path = '%s' WHERE number = 99;", name, path)
  self:exec(query)
end

function Database:selectfile()
  return self:exec("SELECT * FROM tbl_file WHERE number = 99;")
end

function dbtasks.Database(...)
  return Database(...)
end

return dbtasks
