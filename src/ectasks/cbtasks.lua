require("common.extension")

local ui             = require("ui")
local uidialogs      = require("module.uidialogs")
local json           = require("json")

local dbtasks        = require("resource.dbtasks")
local ditranslations = require("resource.ditranslations")
local liapplication  = require("resource.liapplication")

--#region db initialization

local db             = (arg[1] == nil) and dbtasks.Database(":memory:") or dbtasks.Database(arg[1])
db.sort              = dbtasks.SORT.SequenceDESC
db.show              = dbtasks.SHOW.AllTasks
db.filter            = nil
db.page              = 0
db.pages             = 0
db.count             = 0

--#endregion

--#region win initialization

local win            = require("uitasks")
win.title            = liapplication.NAME

--#endregion

--#region window methods

function win:updatetitle()
  self.title = liapplication.NAME .. " - " .. (db.file ~= ":memory:" and db.file.name or db.file)
end

function win:updatestatus()
  local statusText = string.rep(" ", 3)
  statusText = statusText .. self.LM:translate("StatusPage")
  statusText = statusText .. (db.page + 1) .. " / " .. db.pages
  statusText = statusText .. string.rep(" ", 6)
  statusText = statusText .. self.LM:translate(db.sort)
  statusText = statusText .. string.rep(" ", 6)
  statusText = statusText .. self.LM:translate(db.show)
  statusText = statusText .. string.rep(" ", 6)
  if db.filter then
    statusText = statusText .. self.LM:translate("StatusFilter") .. db.filter
  else
    statusText = statusText .. self.LM:translate("StatusNoFilter")
  end
  self:status(statusText)
end

function win:updatelist()
  self.WM_DATA.children.PanelTasks:change("text", "")
  self.WM_DATA.children.PanelTasks:change("checked", false)
  self.WM_DATA.children.PanelTasks:change("sequence", nil)

  local rows = self.WM_DATA.children.PanelTasks.rows

  local i = 1

  for task in db:select(db.page * rows, db.sort, db.show, db.filter) do
    self.WM_DATA.children.PanelTasks.items[i].text = task.subject
    self.WM_DATA.children.PanelTasks.items[i].sequence = task.sequence
    self.WM_DATA.children.PanelTasks.items[i].checked = task.status == 1

    i = i + 1
  end

  db.count = db:countfiltered(db.show, db.filter)
  db.pages = math.ceil(db.count / rows)
end

function win:updatewidgets()
  if db.pages == 0 then
    win.WM_DATA:disable()
    win.WM_NAVIGATION:disable()
  elseif db.pages == 1 then
    win.WM_DATA:enable()
    win.WM_NAVIGATION:disable()
  else
    win.WM_DATA:enable()
    win.WM_NAVIGATION:enable()
  end

  if win.WM_DATA.children.ButtonFilter.text == "( X )" then
    win.WM_DATA.children.ButtonFilter.enabled = true
  end
end

--#endregion

--#region entry events
function win.WM_ENTRY.children.EntryTask:onSelect()
  win.WM_ENTRY.children.ButtonAdd:onClick()
end

--#endregion

--#region button events

function win.WM_ENTRY.children.ButtonFile:onClick()
  local currentFile = ui.opendialog("", false, win.LM:translate("FilesAll"))

  if not isnil(currentFile) then
    win.WM_ENTRY.children.LinkFile.text = currentFile.name
    win.WM_ENTRY.children.LinkFile.link = currentFile.fullpath
    db:updatefile(currentFile.name, currentFile.fullpath)
  end

  win.WM_ENTRY:focus("EntryTask")
end

function win.WM_ENTRY.children.ButtonAdd:onClick()
  if win.WM_ENTRY.children.EntryTask.modified then
    win.WM_ENTRY.children.EntryTask.text = string.trim(win.WM_ENTRY.children.EntryTask.text)

    win.VM:apply()

    if win.VM.isvalid then
      db:insert(win.WM_ENTRY.children.EntryTask.text)
    else
      local errorText = ""

      for _, text in ipairs(win.VM.message) do
        errorText = errorText .. win.LM:translate(text) .. "\n"
      end

      ui.warn(errorText, win.LM:translate("DialogTitleWarning"))
    end
  end

  win:updatelist()
  win:updatestatus()
  win:updatewidgets()

  win.WM_ENTRY.children.EntryTask.text = ""
  win.WM_ENTRY:focus("EntryTask")
end

function win.WM_NAVIGATION.children.ButtonFirst:onClick()
  if db.page ~= 0 then
    db.page = 0
    win:updatelist()
    win:updatestatus()
  end

  win.WM_ENTRY:focus("EntryTask")
end

function win.WM_NAVIGATION.children.ButtonPrevious:onClick()
  if db.page > 0 then
    db.page = db.page - 1
    win:updatelist()
    win:updatestatus()
  end

  win.WM_ENTRY:focus("EntryTask")
end

function win.WM_DATA.children.ButtonFilter:onClick()
  if isnil(db.filter) then
    local filterResult = uidialogs.textentrydialog(win, win.LM:translate("DialogTitleFilter"),
      win.LM:translate("DialogMessageFilter"))

    if filterResult ~= nil and string.trim(filterResult) ~= "" then
      db.filter = filterResult
      self.text = "( X )"
      db.page = 0

      win:updatelist()
      win:updatewidgets()
      win:updatestatus()

      win.WM_ENTRY:focus("EntryTask")
    end
  else
    db.filter = nil
    self.text = "(   )"
    db.page = 0

    win:updatelist()
    win:updatewidgets()
    win:updatestatus()

    win.WM_ENTRY:focus("EntryTask")
  end
end

function win.WM_NAVIGATION.children.ButtonNext:onClick()
  if db.page < db.pages - 1 then
    db.page = db.page + 1
    win:updatelist()
    win:updatestatus()
  end

  win.WM_ENTRY:focus("EntryTask")
end

function win.WM_NAVIGATION.children.ButtonLast:onClick()
  if db.page ~= db.pages - 1 then
    db.page = db.pages - 1
    win:updatelist()
    win:updatestatus()
  end

  win.WM_ENTRY:focus("EntryTask")
end

--#endregion

--#region menu events

function win.MM_APP.children.MenuAppEnglish:onClick()
  win.LM.dictionary = ditranslations.english
  win.LM.language = ditranslations.English_United_States
  win.LM:apply()

  win.MM_APP:uncheck()
  self.checked = true

  win:updatestatus()

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_APP.children.MenuAppGerman:onClick()
  win.LM.dictionary = ditranslations.german
  win.LM.language = ditranslations.German_Germany
  win.LM:apply()

  win.MM_APP:uncheck()
  self.checked = true

  win:updatestatus()

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_APP.children.MenuAppExit:onClick()
  if db.file == ":memory:" then
    local confirmSave = ui.confirm(win.LM:translate("DialogMessageSave"), win.LM:translate("DialogTitleConfirmation"))

    if confirmSave == "cancel" then
      win.WM_ENTRY:focus("EntryTask")
      return false
    end

    if confirmSave == "yes" then
      win.MM_FILE.children.MenuFileSave:onClick()
    end
  end

  db:close()
  win:hide()
end

function win.MM_FILE.children.MenuFileCreate:onClick()
  db        = dbtasks.Database(":memory:")
  db.sort   = dbtasks.SORT.SequenceDESC
  db.show   = dbtasks.SHOW.AllTasks
  db.filter = nil
  db.page   = 0
  db.pages  = 0
  db.count  = 0

  win.MM_SORT:uncheck()
  win.MM_SORT.children.MenuSortSequenceDESC.checked = true
  win.MM_SHOW:uncheck()
  win.MM_SHOW.children.MenuShowAllTasks.checked = true

  win.WM_ENTRY.children.LinkFile.text = win.LM:translate("FileUnknown")
  win.WM_DATA.children.ButtonFilter.text = "(   )"

  win:updatelist()
  win:updatewidgets()
  win:updatetitle()
  win:updatestatus()

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_FILE.children.MenuFileOpen:onClick()
  local currentFile = ui.opendialog("", false, win.LM:translate("FilesTask"))

  if currentFile ~= nil then
    db        = dbtasks.Database(currentFile.fullpath)
    db.sort   = dbtasks.SORT.SequenceDESC
    db.show   = dbtasks.SHOW.AllTasks
    db.filter = nil
    db.page   = 0
    db.pages  = 0
    db.count  = 0

    win.MM_SORT:uncheck()
    win.MM_SORT.children.MenuSortSequenceDESC.checked = true
    win.MM_SHOW:uncheck()
    win.MM_SHOW.children.MenuShowAllTasks.checked = true
    win.WM_DATA.children.ButtonFilter.text = "(   )"

    local linkedFile = db:selectfile()
    win.WM_ENTRY.children.LinkFile.text = (#linkedFile.name ~= 0) and linkedFile.name or win.LM:translate("FileUnknown")
    win.WM_ENTRY.children.LinkFile.link = linkedFile.path

    win:updatelist()
    win:updatewidgets()
    win:updatetitle()
    win:updatestatus()

    win.WM_ENTRY:focus("EntryTask")
  end
end

function win.MM_FILE.children.MenuFileSave:onClick()
  local saveFile = ui.savedialog("", false, win.LM:translate("FilesTasks"))

  if saveFile ~= nil then
    db:save(saveFile.fullpath)

    local saveProperties = {
      sort   = db.sort,
      show   = db.show,
      filter = db.filter,
      page   = db.page,
      pages  = db.pages,
      count  = db.count
    }

    db                   = dbtasks.Database(saveFile.fullpath)
    db.sort              = saveProperties.sort
    db.show              = saveProperties.show
    db.filter            = saveProperties.filter
    db.page              = saveProperties.page
    db.pages             = saveProperties.pages
    db.count             = saveProperties.count

    win:updatetitle()

    win.WM_ENTRY:focus("EntryTask")
  end
end

function win.MM_FILE.children.MenuFileInfo:onClick()
  local infoText = ""

  infoText = tostring(db:countall()) .. win.LM:translate("InfoTasksAll")
  infoText = infoText .. "\n\n" .. tostring(db:countactive()) .. win.LM:translate("InfoTasksActive")
  infoText = infoText .. "\n\n" .. tostring(db:countcompleted()) .. win.LM:translate("InfoTasksCompleted")

  if not isnil(db.filter) then
    infoText = infoText ..
        "\n\n" .. tostring(db:countfiltered(db.show, db.filter) .. win.LM:translate("InfoTasksFiltered"))
  end

  ui.info(infoText, win.LM:translate("DialogTitleInformation"))

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SORT.children.MenuSortSequenceASC:onClick()
  db.sort = dbtasks.SORT.SequenceASC

  win:updatelist()
  win:updatestatus()

  win.MM_SORT:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SORT.children.MenuSortSequenceDESC:onClick()
  db.sort = dbtasks.SORT.SequenceDESC

  win:updatelist()
  win:updatestatus()

  win.MM_SORT:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SORT.children.MenuSortSubjectASC:onClick()
  db.sort = dbtasks.SORT.SubjectASC

  win:updatelist()
  win:updatestatus()

  win.MM_SORT:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SORT.children.MenuSortSubjectDESC:onClick()
  db.sort = dbtasks.SORT.SubjectDESC

  win:updatelist()
  win:updatestatus()

  win.MM_SORT:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SORT.children.MenuSortStatusASC:onClick()
  db.sort = dbtasks.SORT.StatusASC

  win:updatelist()
  win:updatestatus()

  win.MM_SORT:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SORT.children.MenuSortStatusDESC:onClick()
  db.sort = dbtasks.SORT.StatusDESC

  win:updatelist()
  win:updatestatus()

  win.MM_SORT:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SHOW.children.MenuShowAllTasks:onClick()
  db.show = dbtasks.SHOW.AllTasks
  db.page = 0

  win:updatelist()
  win:updatewidgets()
  win:updatestatus()

  win.MM_SHOW:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SHOW.children.MenuShowActiveTasks:onClick()
  db.show = dbtasks.SHOW.ActiveTasks
  db.page = 0

  win:updatelist()
  win:updatewidgets()
  win:updatestatus()

  win.MM_SHOW:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_SHOW.children.MenuShowCompletedTasks:onClick()
  db.show = dbtasks.SHOW.CompletedTasks
  db.page = 0

  win:updatelist()
  win:updatewidgets()
  win:updatestatus()

  win.MM_SHOW:uncheck()
  self.checked = true

  win.WM_ENTRY:focus("EntryTask")
end

function win.MM_HELP.children.MenuHelpAbout:onClick()
  local helpText = liapplication.NAME .. " " .. liapplication.VERSION .. "\n\n"
  helpText = helpText .. liapplication.DEVELOPER .. " " .. liapplication.COPYRIGHT .. "\n\n"
  helpText = helpText .. liapplication.WEBSITE

  ui.info(helpText, win.LM:translate("DialogTitleAbout"))

  win.WM_ENTRY:focus("EntryTask")
end

--#endregion

--#region panel events

function win.WM_DATA.children.PanelTasks:onCreate()
  super(self).onCreate(self)

  for key, child in pairs(self.items) do
    child.onClick = function()
      if not isinteger(win.WM_DATA.children.PanelTasks.items[key].sequence) then
        win.WM_DATA.children.PanelTasks.items[key].checked = false
        return
      end
      db:updatestatus(win.WM_DATA.children.PanelTasks.items[key].sequence,
        win.WM_DATA.children.PanelTasks.items[key].checked)
      win:updatelist()
    end
  end
end

function win.WM_DATA.children.PanelEdit:onCreate()
  super(self).onCreate(self)

  for key, child in pairs(self.items) do
    child.text = "#"
    child.onClick = function()
      if not isinteger(win.WM_DATA.children.PanelTasks.items[key].sequence) then return end

      uidialogs.cancelcaption = win.LM:translate("CaptionCancel")
      uidialogs.confirmcaption = win.LM:translate("CaptionConfirm")

      local editResult = uidialogs.textentrydialog(win, win.LM:translate("DialogTitleEdit"),
        win.LM:translate("DialogMessageEdit") .. " # " .. win.WM_DATA.children.PanelTasks.items[key].sequence,
        win.WM_DATA.children.PanelTasks.items[key].text)

      if editResult ~= nil and string.trim(editResult) ~= "" then
        db:updatesubject(win.WM_DATA.children.PanelTasks.items[key].sequence, editResult)
        win:updatelist()
      end
    end

    win.LM:add(win.WM_DATA.children.PanelEdit.items[key], "tooltip", "ButtonEdit")
  end
end

function win.WM_DATA.children.PanelDelete:onCreate()
  super(self).onCreate(self)

  for key, child in pairs(self.items) do
    child.text = "X"
    child.onClick = function()
      if not isinteger(win.WM_DATA.children.PanelTasks.items[key].sequence) then return end
      db:delete(win.WM_DATA.children.PanelTasks.items[key].sequence)
      win:updatelist()
    end

    win.LM:add(win.WM_DATA.children.PanelDelete.items[key], "tooltip", "ButtonDelete")
  end
end

--#endregion

--#region window events

function win:onCreate()
  win:center()
  win:status()

  win.GM_HEADER:apply()
  win.GM_INPUT:apply()
  win.GM_TABLE:apply()
  win.GM_FOOTER:apply()

  if liapplication.SETTINGS.file.exists then
    win.CM.settings = json.load(liapplication.SETTINGS.file)
  end

  if win.CM.settings == nil or next(win.CM.settings) == nil then
    win.CM.settings = liapplication.SETTINGS.default
  end

  win.CM:apply()
end

function win:onShow()
  if win.CM:setting("MenuAppEnglish") == true then
    win.LM.dictionary = ditranslations.english
    win.LM.language = ditranslations.English_United_States
  end

  if win.CM:setting("MenuAppGerman") == true then
    win.LM.dictionary = ditranslations.german
    win.LM.language = ditranslations.German_Germany
  end

  win.LM:apply()

  if db.file == ":memory:" then
    win.WM_ENTRY.children.LinkFile.text = win.LM:translate("FileUnknown")
  else
    local linkedFile = db:selectfile()
    win.WM_ENTRY.children.LinkFile.text = (#linkedFile.name ~= 0) and linkedFile.name or win.LM:translate("FileUnknown")
    win.WM_ENTRY.children.LinkFile.link = linkedFile.path
  end

  win.WM_DATA.children.ButtonFilter.text = "(   )"

  win:updatelist()
  win:updatewidgets()
  win:updatestatus()
  win:updatetitle()

  win.WM_ENTRY:focus("EntryTask")
end

function win:onResize()
  win.WM_ENTRY:focus("EntryTask")
end

function win:onHide()
  win.CM:update("MenuAppEnglish", win.MM_APP.children.MenuAppEnglish.checked)
  win.CM:update("MenuAppGerman", win.MM_APP.children.MenuAppGerman.checked)
  json.save(liapplication.SETTINGS.file, win.CM.settings)
end

function win:onClose()
  if db.file == ":memory:" then
    local confirmSave = ui.confirm(win.LM:translate("DialogMessageSave"), win.LM:translate("DialogTitleConfirmation"))

    if confirmSave == "cancel" then
      return false
    end

    if confirmSave == "yes" then
      win.MM_FILE.children.MenuFileSave:onClick()
    end
  end

  db:close()
end

--#endregion

ui.run(win):wait()
