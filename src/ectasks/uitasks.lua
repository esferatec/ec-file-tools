local ui = require("ui")
local uiextension = require("module.uiextension")

local wm = require("manager.wm") -- widget manager
local mm = require("manager.mm") -- menu manager
local gm = require("manager.gm") -- geometry manager
local lm = require("manager.lm") -- localization manager
local vm = require("manager.vm") -- validation manager
local cm = require("manager.cm") -- configuration manager

local function isRequired(value)
  return string.trim(value) ~= nil and string.trim(value) ~= ""
end

local Window = ui.Window("ecTasks", "single", 427, 616)

Window.WM_ENTRY = wm.WidgetManager()
Window.WM_DATA = wm.WidgetManager()
Window.WM_NAVIGATION = wm.WidgetManager()
Window.MM_APP = mm.MenuManager()
Window.MM_FILE = mm.MenuManager()
Window.MM_SORT = mm.MenuManager()
Window.MM_SHOW = mm.MenuManager()
Window.MM_HELP = mm.MenuManager()
Window.GM_HEADER = gm.GeometryManager():TopLayout(Window, gm.DIRECTION.Left, 8, { 10, 10, 20, 0 }, 24)
Window.GM_INPUT = gm.GeometryManager():TopLayout(Window, gm.DIRECTION.Left, 8, { 10, 10, 64, 0 }, 48)
Window.GM_TABLE = gm.GeometryManager():RowLayout(Window, gm.DIRECTION.Left, 8, 15, 132, 402, 376)
Window.GM_FOOTER = gm.GeometryManager():BottomLayout(Window, gm.DIRECTION.Left, 8, { 10, 10, 0, 64 }, 24)
Window.LM = lm.LocalizationManager()
Window.VM = vm.ValidationManager()
Window.CM = cm.ConfigurationManager()

Window.menu = ui.Menu()

local MenuApp = ui.Menu("English", "German", "", "Exit")
Window.menu:add("|||", MenuApp)
Window.MM_APP:add(MenuApp.items[1], "MenuAppEnglish")
Window.MM_APP:add(MenuApp.items[2], "MenuAppGerman")
Window.MM_APP:add(MenuApp.items[4], "MenuAppExit")
Window.LM:add(Window.menu.items[1], "text", "MenuApp")
Window.LM:add(MenuApp.items[1], "text", "MenuAppEnglish")
Window.LM:add(MenuApp.items[2], "text", "MenuAppGerman")
Window.LM:add(MenuApp.items[4], "text", "MenuAppExit")
Window.CM:add(MenuApp.items[1], "checked", "MenuAppEnglish")
Window.CM:add(MenuApp.items[2], "checked", "MenuAppGerman")

local MenuFile = ui.Menu("Create", "Open", "Save", "", "Info")
Window.menu:add("File", MenuFile)
Window.MM_FILE:add(MenuFile.items[1], "MenuFileCreate")
Window.MM_FILE:add(MenuFile.items[2], "MenuFileOpen")
Window.MM_FILE:add(MenuFile.items[3], "MenuFileSave")
Window.MM_FILE:add(MenuFile.items[5], "MenuFileInfo")
Window.LM:add(Window.menu.items[2], "text", "MenuFile")
Window.LM:add(MenuFile.items[1], "text", "MenuFileCreate")
Window.LM:add(MenuFile.items[2], "text", "MenuFileOpen")
Window.LM:add(MenuFile.items[3], "text", "MenuFileSave")
Window.LM:add(MenuFile.items[5], "text", "MenuFileInfo")

local MenuSort = ui.Menu("Sequence ASC", "Sequence DESC", "", "Subject ASC", "Subject DESC", "", "Status ASC", "Status DESC")
Window.menu:add("Sort", MenuSort)
Window.MM_SORT:add(MenuSort.items[1], "MenuSortSequenceASC")
Window.MM_SORT:add(MenuSort.items[2], "MenuSortSequenceDESC")
Window.MM_SORT:add(MenuSort.items[4], "MenuSortSubjectASC")
Window.MM_SORT:add(MenuSort.items[5], "MenuSortSubjectDESC")
Window.MM_SORT:add(MenuSort.items[7], "MenuSortStatusASC")
Window.MM_SORT:add(MenuSort.items[8], "MenuSortStatusDESC")
Window.LM:add(Window.menu.items[3], "text", "MenuSort")
Window.LM:add(MenuSort.items[1], "text", "MenuSortSequenceASC")
Window.LM:add(MenuSort.items[2], "text", "MenuSortSequenceDESC")
Window.LM:add(MenuSort.items[4], "text", "MenuSortSubjectASC")
Window.LM:add(MenuSort.items[5], "text", "MenuSortSubjectDESC")
Window.LM:add(MenuSort.items[7], "text", "MenuSortStatusASC")
Window.LM:add(MenuSort.items[8], "text", "MenuSortStatuseDESC")
Window.CM:add(MenuSort.items[1], "checked", "MenuSortSequenceASC")

local MenuShow = ui.Menu("All Tasks", "", "Active Tasks", "Completed Tasks")
Window.menu:add("Show", MenuShow)
Window.MM_SHOW:add(MenuShow.items[1], "MenuShowAllTasks")
Window.MM_SHOW:add(MenuShow.items[3], "MenuShowActiveTasks")
Window.MM_SHOW:add(MenuShow.items[4], "MenuShowCompletedTasks")
Window.LM:add(Window.menu.items[4], "text", "MenuShow")
Window.LM:add(MenuShow.items[1], "text", "MenuShowAllTasks")
Window.LM:add(MenuShow.items[3], "text", "MenuShowActiveTasks")
Window.LM:add(MenuShow.items[4], "text", "MenuShowCompletedTasks")
Window.CM:add(MenuShow.items[1], "checked", "MenuShowAllTasks")

local MenuHelp = ui.Menu("About")
Window.menu:add("Help", MenuHelp)
Window.MM_HELP:add(MenuHelp.items[1], "MenuHelpAbout")
Window.LM:add(Window.menu.items[5], "text", "MenuHelp")
Window.LM:add(MenuHelp.items[1], "text", "MenuHelpAbout")

local LinkFile = uiextension.FileLink(Window, "", 0, 0, 343)
LinkFile.textalign = "center"
LinkFile.fontsize = Window.fontsize + 2
LinkFile.fontstyle = { ["bold"] = true }
LinkFile.link = ""
Window.WM_ENTRY:add(LinkFile, "LinkFile")
Window.GM_HEADER:add(LinkFile, gm.ALIGNMENT.Center)

local ButtonFile = ui.Button(Window, "...", 0, 0, 56, 24)
Window.WM_ENTRY:add(ButtonFile, "ButtonFile")
Window.GM_HEADER:add(ButtonFile)
Window.LM:add(ButtonFile, "tooltip", "ButtonFile")

local EntryTask = ui.Entry(Window, "", 0, 0, 343, 24)
EntryTask.textlimit = "100"
Window.WM_ENTRY:add(EntryTask, "EntryTask")
Window.GM_INPUT:add(EntryTask, gm.ALIGNMENT.Center)
Window.LM:add(EntryTask, "tooltip", "EntryTask")
Window.VM:add(EntryTask, "text", isRequired, "SubjectRequired")

local ButtonAdd = ui.Button(Window, "+", 0, 0, 56, 48)
Window.WM_ENTRY:add(ButtonAdd, "ButtonAdd")
Window.GM_INPUT:add(ButtonAdd)
Window.LM:add(ButtonAdd, "tooltip", "ButtonAdd")

local PanelTasks = uiextension.ColumnPanel(Window, uiextension.StrikeCheckbox, 12, 8, 0, 0, 338, 376)
Window.WM_DATA:add(PanelTasks, "PanelTasks")
Window.GM_TABLE:add(PanelTasks)

local PanelEdit = uiextension.ColumnPanel(Window, ui.Button, 12, 8, 0, 0, 24, 376)
Window.WM_DATA:add(PanelEdit, "PanelEdit")
Window.GM_TABLE:add(PanelEdit)

local PanelDelete = uiextension.ColumnPanel(Window, ui.Button, 12, 8, 0, 0, 24, 376)
Window.WM_DATA:add(PanelDelete, "PanelDelete")
Window.GM_TABLE:add(PanelDelete)

local ButtonFirst = ui.Button(Window, "|<", 0, 0, 75, 24)
Window.WM_NAVIGATION:add(ButtonFirst, "ButtonFirst")
Window.GM_FOOTER:add(ButtonFirst)
Window.LM:add(ButtonFirst, "tooltip", "ButtonFirst")

local ButtonPrevious = ui.Button(Window, "<", 0, 0, 75, 24)
Window.WM_NAVIGATION:add(ButtonPrevious, "ButtonPrevious")
Window.GM_FOOTER:add(ButtonPrevious)
Window.LM:add(ButtonPrevious, "tooltip", "ButtonPrevious")

local ButtonFilter = ui.Button(Window, "(  )", 0, 0, 75, 24)
Window.WM_DATA:add(ButtonFilter, "ButtonFilter")
Window.GM_FOOTER:add(ButtonFilter)
Window.LM:add(ButtonFilter, "tooltip", "ButtonFilter")

local ButtonNext = ui.Button(Window, ">", 0, 0, 75, 24)
Window.WM_NAVIGATION:add(ButtonNext, "ButtonNext")
Window.GM_FOOTER:add(ButtonNext)
Window.LM:add(ButtonNext, "tooltip", "ButtonNext")

local ButtonLast = ui.Button(Window, ">|", 0, 0, 75, 24)
Window.WM_NAVIGATION:add(ButtonLast, "ButtonLast")
Window.GM_FOOTER:add(ButtonLast)
Window.LM:add(ButtonLast, "tooltip", "ButtonLast")

return Window
