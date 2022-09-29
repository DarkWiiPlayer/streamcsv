local streamcsv, name = {}, ...

streamcsv.read = require(name .. ".read")
streamcsv.write = require(name .. ".write")

function streamcsv.header(record, header)
	for position, name in ipairs(header) do
		record[header[position]] = record[position]
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

--- Returns an iterator over records in a CSV file
-- @param input A CSV-String or io-object to parse
-- @tparam[opt] table Options
function streamcsv.records(input, options)
	if type(options) ~= "table" then options=nil end

	local colsep, rowsep, sep
	if options then
		colsep, rowsep, sep = options.colsep, options.rowsep
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

--- Reads a whole file into a table using streamcsv.records
function streamcsv.file(input, options)
	local result = {}
	for index, record in streamcsv.records(input, options) do
		result[index] = record
	end
	return result
end

return streamcsv
