StreamCSV
================================================================================

A CSV-Parsing library with an emphasis on performance.

StreamCSV can read CSV data from streams of data.
This means you can parse arbitrarily large amounts of data without having to fit
it all into memory at once.

## The high-level `streamcsv` module

A simple example, this will iterate over all records ("lines") of a CSV file:

```lua
for idx, record in streamcsv.records(io.open("test.csv")) do
	print(table.unpack(record))
end
```

This file will be treated as having no initial header line. To indicate that the
first line should be read as a header, set the `header` option to true:

```lua
for idx, record in streamcsv.records(io.open("test2.csv", {header=true})) do
	print(table.unpack(record))
end
```

When a header is not part of the CSV file, but is otherwise known, it can be
passed explicitly:

```lua
for idx, record in streamcsv.records("1,2,3", header="a,b,c")
-- or
for idx, record in streamcsv.records("1,2,3", header={"a", "b", "c"})
```

## The low-level `streamcsv.read` module

Generally, all the functions of this module are structured as follows:

### Arguments

1. An initial string (can be empty)
3. At what position in the initial string to start parsing
2. A string containing the record and field separators (default `"\n,"`)
4. A generator function that returns the next string from the stream or nil

Note that if the generator function should return an empty string, the parser
functions will immediately attempt to call it again, potentially leading to an
endless loop.

### Return values

1. The main result of the function
2. The new current string (same as argument, or result of generator)
3. The first position in the current string that has not yet been consumed
