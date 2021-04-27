local write = {}

local read = require((...):gsub("write","read"))

function write.field(field, sep)
	sep = sep or "\n,"
	field = tostring(field)
	if field:find("["..sep.."]") or field:find('^"') then
		return '"'..field:gsub('"', '""')..'"'
	else
		return field
	end
end

function write.record(record, header, sep)
	sep = sep or "\n,"
	if type(header)=="string" then
		header = read.record(header, 1, sep)
	end
	local buf = {}
	if header then
		for i, name in ipairs(header) do
			buf[i] = write.field(record[i] or record[name], sep)
		end
	else
		for i, field in ipairs(record) do
			buf[i] = write.field(field, sep)
		end
	end
	return table.concat(buf, sep:sub(2,2))
end

function write.file(file, header, sep)
	sep = sep or "\n,"
	if type(header)=="string" then
		header = read.record(header, 1, sep)
	end
	local buf = {}
	if header then
		buf[1]=write.record(header)
		for i, record in ipairs(file) do
			buf[i+1] = write.record(record, header, sep)
		end
	else
		for i, record in ipairs(file) do
			buf[i] = write.record(record, header, sep)
		end
	end
	return table.concat(buf, sep:sub(1,1))
end

return write
