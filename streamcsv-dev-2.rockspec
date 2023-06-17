package = "streamcsv"
version = "dev-2"
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
		["streamcsv"]= "src/streamcsv.lua";
		["streamcsv.read"] = "src/streamcsv/read.lua";
		["streamcsv.write"] = "src/streamcsv/write.lua";
	}
}
