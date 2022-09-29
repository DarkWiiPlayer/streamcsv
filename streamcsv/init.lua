--- High-level module for parsing CSV date
-- @module streamcsv

local streamcsv, modname = {}, ...

streamcsv.read = require(modname .. ".read")
streamcsv.write = require(modname .. ".write")

--- Adds headers to a record.
-- Note that the resulting record saves a direct reference to the header as passed into this function at index `[0]`, so modifying this value could cause trouble elsewhere.
-- @tparam sequence record Input record as a list of values
-- @tparam sequence header as list of keys
-- @treturn table Record containing its values as integer (position) and string (header) indices, and the header at the `[0]`th index
function streamcsv.header(record, header)
	for position, name in ipairs(header) do
		record[name] = record[position]
		record[0] = header
	end
end

local function nextrecord(state, counter)
	local record, current, first = streamcsv.read.record(state[1], state[2], state[3], state[4])
	state[1], state[2] = current, first and first+1
	if state.header then
		streamcsv.header(record, state.header)
	end
	if first then
		return counter+1, record
	else
		return nil
	end
end

--- Options table to be passed to `streamcsv.records` and `streamcsv.file`
-- @tfield string rowsep A single character representing the row separator.
-- @tfield string colsep A single character representing the column separator.
-- @field header A CSV string or Lua sequence containing the header values, or any other truthy value to read the first row of the input data.
-- @tfield integer block The (max) block size in bytes to consume at a time. Defaults to 4MB.
-- @table options

--- Returns an iterator over records in a CSV file
-- @param input A CSV-String or io-object to parse
-- @tparam[opt] options options
function streamcsv.records(input, options)
	if type(options) ~= "table" then options=nil end

	local colsep, rowsep, sep
	if options then
		colsep, rowsep, sep = options.colsep, options.rowsep, nil
		if rowsep and colsep then
			sep = rowsep..colsep
		elseif rowsep then
			sep = rowsep..","
		elseif colsep then
			sep = "\n"..colsep
		end
	end

	local state
	if type(input) == "string" then
		state = {input, 1, sep, nil}
	elseif type(input) == "userdata" then
		local size = options and options.block or 4 * 1024 ^ 2 -- 4MB block size
		state = {"", 1, sep, function()
			return input:read(size)
		end}
	elseif type(input) == "table" then
		state = input
	else
		error("Invalid type for input: "..type(input))
	end

	if options then
		if type(options.header) == "table" then
			state.header = options.header
		elseif type(options.header) == "string" then
			state.header = streamcsv.read.record(options.header, 1, sep)
		elseif options.header then
			state.header, state[1], state[2] = streamcsv.read.record(state[1], state[2], state[3], state[4])
			state[2] = state[2]+1
		end
	end

	return nextrecord, state, 0
end

--- Reads a whole file into a table using streamcsv.records.
-- Note that a "file" in this context refers to a collection of CSV records, not an OS-level file.
-- @param input A string containing CSV data or a readable I/O object
-- @tparam[opt] options options
function streamcsv.file(input, options)
	local result = {}
	for index, record in streamcsv.records(input, options) do
		result[index] = record
	end
	return result
end

return streamcsv
