local sys = require("sys")

local liapplication = {}

liapplication.NAME = "ecTasks"

liapplication.VERSION = "0.1.0"

liapplication.WEBSITE = "https://github.com/esferatec/"

liapplication.COPYRIGHT = "(c) 2024"

liapplication.DEVELOPER = "esferatec"

liapplication.SETTINGS = {
  file = sys.File("ectasks.json"),
  default = {
    MenuAppEnglish = true,
    MenuAppGerman = false,
    MenuSortSequenceASC = true,
    MenuShowAllTasks = true
  }
}

return liapplication
