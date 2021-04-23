StreamCSV
================================================================================

A CSV-Parsing library with an emphasis on performance.

StreamCSV can read CSV data from streams of data.
This means you can parse arbitrarily large amounts of data without having to fit
it all into memory at once.

Generally, all the functions are structured as follows:

### Arguments

1. An initial string (can be empty)
2. A string containing the record and field separators (default `"\n,"`)
3. At what position in the initial string to start parsing
4. A generator function that returns the next string from the stream or nil

Note that if the generator function should return an empty string, the parser
functions will immediately attempt to call it again, potentially leading to an
endless loop.

### Return values

1. The main result of the function
2. The new current string (same as argument, or result of generator)
3. The first position in the current string that has not yet been consumed
