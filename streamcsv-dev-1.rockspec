package = "streamcsv"
version = "dev-1"
source = {
   url = "https://github.com/darkwiiplayer/streamcsv.git"
}
description = {
   homepage = "https://github.com/darkwiiplayer/streamcsv",
   license = "Unlicense"
}
build = {
   type = "builtin",
   modules = {
      ["streamcsv"]= "streamcsv/init.lua";
      ["streamcsv.read"] = "streamcsv/read.lua";
   }
}
