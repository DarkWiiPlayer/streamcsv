csv = require 'streamcsv'

iter = (str, pattern) ->
	coroutine.wrap ->
		coroutine.yield sub for sub in str\gmatch(pattern)
		while true
			coroutine.yield nil

describe '#field parser', ->
	describe 'without consumer', ->
		it 'handles initial positions', ->
			assert.equal 'foo', csv.read.ufield 'foo,bar,baz'
		it 'handles in-between positions', ->
			assert.equal 'bar', csv.read.ufield 'foo,bar,baz', nil, 5
		it 'handles final positions', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,baz', nil, 9
		it 'handles empty fields', ->
			assert.equal '', csv.read.ufield 'foo,,bar', nil, 5
	describe 'with consumer', ->
		it 'handles final positions', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,baz', nil, 9, -> nil
		it 'handles interrupted final fields', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,b', nil, 9, iter 'az', '.'
		it 'handles interrupted in-between fields', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,b', nil, 9, iter 'az,ree', '.'
		it 'handles empty positions', ->
			assert.equal 'foo', csv.read.ufield '', nil, 1, iter 'foo,bar,baz', '.'
		it 'handles empty final fields', ->
			assert.equal '', csv.read.ufield '', nil, 1, -> nil
		it 'handles broken-off positions', ->
			field, current, first = csv.read.ufield 'fo', nil, 1, iter 'o,bar,baz', '...'
			assert.equal 'foo', field
			assert.equal 'o,b', current
			assert.equal 2, first

describe '#quoted field parser', ->
	describe 'without consumer', ->
		it 'handles initial positions', ->
			assert.equal 'foo', csv.read.qfield '"foo","bar","baz"'
		it 'handles in-between positions', ->
			assert.equal 'bar', csv.read.qfield '"foo","bar","baz"', nil, 7
		it 'handles final positions', ->
			assert.equal 'baz', csv.read.qfield '"foo","bar","baz"', nil, 13
		it 'handles empty fields', ->
			assert.equal '', csv.read.qfield '"foo","","bar"', nil, 7
		it 'handles escaped quotes', ->
			assert.equal 'a"b', csv.read.qfield '"a""b"'
	describe 'with consumer', ->
		it 'handles single characters', ->
			assert.equal 'foo', csv.read.qfield '"', nil, 1, iter 'foo","bar","baz"', '.'
		it 'handles single characters with escaped quotes', ->
			assert.equal 'fo\n"o', csv.read.qfield '', nil, 1, iter '"fo\n""o","bar","baz"', '.'

describe '#record parser', ->
	file = 'foo,bar,baz\nFoo,Bar,Baz\nFOO,BAR,BAZ'
	describe 'without consumer', ->
		it 'handles initial lines', ->
			assert.same {'foo', 'bar', 'baz'}, csv.read.record file
		it 'handles in-between lines', ->
			assert.same {'Foo', 'Bar', 'Baz'}, csv.read.record file, nil, 13
		it 'handles final lines', ->
			assert.same {'FOO', 'BAR', 'BAZ'}, csv.read.record file, nil, 25
	for name, pattern in pairs{character: ".", line: "[^\n]+", unaligned: "..?.?.?.?"}
		describe "with #{name} consumer", ->
			it 'handles empty current strings', ->
				assert.same {'foo', 'bar', 'baz'}, csv.read.record '', nil, 1, iter 'foo,bar,baz', pattern
			it 'handles initialized current strings', ->
				i = iter 'foo,bar,baz', pattern
				assert.same {'foo', 'bar', 'baz'}, csv.read.record i(), nil, 1, i

describe '#file parser', ->
	describe 'without consumer', ->
		it 'reads in a basic file', ->
			assert.same {{"foo", "bar"}, {"baz"}}, csv.read.file 'foo,bar\nbaz'
		it 'reads files with consumer', ->
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', nil, 1, iter '11,12\n21,22', "."
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', nil, 1, iter '11,12\n21,22', "..?"
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', nil, 1, iter '11,12\n21,22', "[^\n]+\n?"
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', "\n;", 1, iter '11;12\n21;22', "."
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', "\n;", 1, iter '11;12\n21;22', "..?"
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', "\n;", 1, iter '11;12\n21;22', "[^\n]+\n?"
