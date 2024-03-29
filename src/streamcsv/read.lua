--- Low-level stream-based functions to parse CSV data.
-- @module streamcsv.read

local read = {}

local Q = ('"'):byte()

--- Parses an un-quoted CSV field.
--- @param current string The (sub-)string that is currently being parsed
--- @param first integer The first unparsed index in current
--- @param sep string Separator pair
--- @param consume fun():string A function that returns the next substring
--- @return string field The main result of the function
--- @return string|nil current The current string snippet returned by `consume`
--- @return number|nil next The next index to be parsed
function read.ufield(current, first, sep, consume)
	first = first or 1
	sep = "["..(sep or "\n,").."]"
	local last = current:find(sep, first)
	if not last then
		local new = consume and consume()
		if new then
			local buffer = {current:sub(first, -1)}
			current = new
			while current do
				first = 1
				last = current:find(sep, first)
				if last then
					table.insert(buffer, current:sub(1, last-1))
					break
				end
				table.insert(buffer, current)
				current = consume()
			end
			return table.concat(buffer), current, last
		else
			return current:sub(first, -1)
		end
	end
	return current:sub(first,last-1), current, last
end

--- Parses a quoted CSV field.
--- @param current string The (sub-)string that is currently being parsed
--- @param first number The first unparsed index in current
--- @param consume fun():string A function that returns the next substring
--- @return string field The main result of the function
--- @return string|nil current The current string snippet returned by `consume`
--- @return integer|nil next The next index to be parsed
function read.qfield(current, first, consume)
	first = first or 1
	local q = Q
	if first > #current then
		current = consume and consume()
		first = 2
	else
		first = first+1 -- Skip initial quote
	end
	-- Special case for when
	-- a) quoted field contains no escaped quotes
	-- b) field ends before more data has to be consumed
	local easy = current:find('"', first, true)
	if easy and current:byte(easy+1, easy+1) ~= q then
		return current:sub(first, easy-1), current, easy+1
	end

	local buffer = {}
	::find::
	local quote = current:find('"', first, true)
	if not quote then
		table.insert(buffer, current:sub(first, -1))
		current = consume and consume()
		if current then
			first = 1
			goto find
		end
	else
		if quote < #current then
			if current:byte(quote+1, quote+1) == q then
				table.insert(buffer, current:sub(first, quote--[[Include first quote]]))
				first = quote+2
				goto find
			else
				table.insert(buffer, current:sub(first, quote-1))
				return table.concat(buffer), current, quote+1
			end
		else
			table.insert(buffer, current:sub(first, quote-1--[[Don't include quote]]))
			current = consume and consume()
			if current then
				if current:byte() == q then
					table.insert(buffer, '"')
					first = 2
					goto find
				else
					return table.concat(buffer), current, 2
				end
			else
				return table.concat(buffer)
			end
		end
	end
	error("End of CSV stream inside quoted field")
end

--- Parses any CSV field.
-- Redirects to the correct field-parsing function depending on whether the
-- field starts with a quote.
--- @param current string The (sub-)string that is currently being parsed
--- @param first number The first unparsed index in current
--- @param sep string Separator pair
--- @param consume fun():string A function that returns the next substring
--- @return string field The main result of the function
--- @return string|nil current The current string snippet returned by `consume`
--- @return number|nil next The next index to be parsed
function read.field(current, first, sep, consume)
	first = first or 1
	if current:byte(first,first) == Q then
		return read.qfield(current, first, consume)
	else
		return read.ufield(current, first, sep, consume)
	end
end

--- Parses lines of CSV items.
--- @param current string The (sub-)string that is currently being parsed
--- @param first integer The first unparsed index in current
--- @param sep string Separator pair
--- @param consume fun():string A function that returns the next substring
--- @return string[] record The main result of the function
--- @return string|nil current The current string snippet returned by `consume`
--- @return integer|nil next The next index to be parsed
function read.record(current, first, sep, consume)
	first = first or 1
	local record = {}
	local field
	sep = sep or '\n,'
	local rsep = sep:byte(1, 1)
	while first do
		field, current, first = read.field(current, first, sep, consume)
		table.insert(record, field)
		if first then
			if current:byte(first, first) == rsep then
				break
			end
			first = first + 1
		end
	end
	return record, current, first
end

--- Parses entire CSV files.
-- A "files" being a collection of recods, not in the sense of the Filesystem.
--- @param current string The (sub-)string that is currently being parsed
--- @param first integer The first unparsed index in current
--- @param sep string Separator pair
--- @param consume fun():string A function that returns the next substring
--- @return string[][] file The main result of the function
function read.file(current, first, sep, consume)
	first = first or 0
	local file = {}
	local record
	while first do
		record, current, first = read.record(current, first, sep, consume)
		table.insert(file, record)
		if first then
			first = first + 1
		end
	end
	return file
end

return read
