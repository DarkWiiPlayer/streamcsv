package = "streamcsv"
version = "dev-1"
source = {
	url = "git+https://github.com/darkwiiplayer/streamcsv.git"
}
description = {
	summary = "A fast library to parse streams of CSV-data as well as generate it",
	homepage = "https://github.com/darkwiiplayer/streamcsv",
	license = "Unlicense"
}
build = {
	type = "builtin",
	modules = {
		["streamcsv"]= "streamcsv/init.lua";
		["streamcsv.read"] = "streamcsv/read.lua";
		["streamcsv.write"] = "streamcsv/write.lua";
	}
}
