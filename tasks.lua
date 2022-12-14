local spooder = require 'spooder'

spooder.task "test" {
	description = "Runs tests";
	depends = "clean";
	[[
		rm luacov.stats.out
		luacheck . || exit
		busted --coverage --lpath '?.lua;?/init.lua' || exit
		luacov -r html streamcsv.lua
	]]
}

spooder.task "documentation" {
	description = "Builds and pushes the documentation";
	depends = { "clean", "test"};
	[[
		hash=$(git log -1 --format=%h)
		mkdir -p doc/coverage
		cp -r luacov-html/* doc/coverage
		ldoc .
		cd doc
			find . | treh -c
			git add --all
			if git log -1 --format=%s | grep "$hash$"
			then git commit --amend --no-edit
			else git commit -m "Update documentation to $hash"
			fi
			git push --force origin doc
		cd ../
		git stash pop || true
	]]
}

spooder.task "clean" {
	description = "Cleans leftover files";
	'rm -rf luacov-html';
	'rm -f luacov.report.out';
	'rm -f luacov.stats.out';
}
