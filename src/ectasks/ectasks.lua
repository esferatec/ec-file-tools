require("common.extension")
local ui = require("ui")
local sys = require("sys")
local json = require("json")

local ROOT = "HKEY_CURRENT_USER"
local KEY = "Software\\Classes\\"
local APP = "ecTasks"

local applicationFolder = sys.File(arg[-1]).path

if arg[1] ~= nil then
  if string.trim(arg[1]) == "uninstall" then
    if ui.confirm("Do you want to remove the file type association from the registry?", APP) == "yes" then
      sys.registry.delete(ROOT, KEY .. ".ectask")
      sys.registry.delete(ROOT, KEY .. "ectask")
      ui.info("File type association removed from the registry", APP)
    end
    sys.exit()
  end

  if string.trim(arg[1]) == "install" then
    if ui.confirm("Do you want to add the file type association to the registry?", APP) == "yes" then
      sys.registry.write(ROOT, KEY .. ".ectask", nil, "ectask")
      sys.registry.write(ROOT, KEY .. "ectask", nil, "ecTasks")
      sys.registry.write(ROOT, KEY .. "ectask\\DefaultIcon", nil, applicationFolder .. "\\ectasks.exe,0")
      sys.registry.write(ROOT, KEY .. "ectask\\shell\\open\\command", nil,
        '"' .. applicationFolder .. '\\ectasks.exe" "%1"')
      ui.info("File type association added to the registry", APP)
    end
    sys.exit()
  end

  if string.find(arg[1], ".ectask") == nil then
    ui.error("This file type ist not supported.", APP)
    sys.exit()
  end
end

local settingsFile = sys.File(applicationFolder .. "\\ectasks.json")

if not settingsFile.exists then
  local defaultSettings = {
    MenuAppEnglish = true,
    MenuAppGerman = false,
    MenuSortSequenceASC = true,
    MenuShowAllTasks = true
  }

  local success, message = pcall(json.save, settingsFile, defaultSettings)

  if not success then
    ui.info(message, APP)
  end
end

dofile(embed.File("cbtasks.lua").fullpath)

if sys.error then
  ui.error(sys.error, APP)
end

sys.exit()
