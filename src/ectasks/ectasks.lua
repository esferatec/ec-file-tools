local ui = require("ui")
local sys = require("sys")
local json = require("json")

--sys.registry.delete("HKEY_CURRENT_USER", "Software\\Classes\\.lua");
--sys.registry.delete("HKEY_CURRENT_USER", "Software\\Classes\\lua")

-- Register *.lua file association
--sys.registry.write("HKEY_CURRENT_USER", "Software\\Classes\\.lua", nil, "lua");
--sys.registry.write("HKEY_CURRENT_USER", "Software\\Classes\\lua", nil, "Lua script");
--sys.registry.write("HKEY_CURRENT_USER", "Software\\Classes\\lua\\DefaultIcon", nil,
--  dir.fullpath .. "\\LuaRT-remove.exe,-102");
--sys.registry.write("HKEY_CURRENT_USER", "Software\\Classes\\lua\\shell\\open\\command", nil,
--  '"' .. dir.fullpath .. '\\bin\\luart.exe" "%1"');

--local fileAssociation = sys.registry.read("HKEY_CURRENT_USER", "Software\\Classes\\.lua")
--ui.info(fileAssociation)

local settingsFile = sys.File("ectasks.json")

if not settingsFile.exists then
  local defaultSettings = {
    MenuAppEnglish = true,
    MenuAppGerman = false,
  }

  json.save(settingsFile, defaultSettings)
end

dofile("cbtasks.lua")

if sys.error then
  ui.error(sys.error)
end

sys.exit()
