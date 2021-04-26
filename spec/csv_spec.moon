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
			assert.equal 'bar', csv.read.ufield 'foo,bar,baz', 5, nil
		it 'handles final positions', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,baz', 9, nil
		it 'handles empty fields', ->
			assert.equal '', csv.read.ufield 'foo,,bar', 5, nil
	describe 'with consumer', ->
		it 'handles final positions', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,baz', 9, nil, -> nil
		it 'handles interrupted final fields', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,b', 9, nil, iter 'az', '.'
		it 'handles interrupted in-between fields', ->
			assert.equal 'baz', csv.read.ufield 'foo,bar,b', 9, nil, iter 'az,ree', '.'
		it 'handles empty positions', ->
			assert.equal 'foo', csv.read.ufield '', 1, nil, iter 'foo,bar,baz', '.'
		it 'handles empty final fields', ->
			assert.equal '', csv.read.ufield '', 1, nil, -> nil
		it 'handles broken-off positions', ->
			field, current, first = csv.read.ufield 'fo', 1, nil, iter 'o,bar,baz', '...'
			assert.equal 'foo', field
			assert.equal 'o,b', current
			assert.equal 2, first

describe '#quoted field parser', ->
	describe 'without consumer', ->
		it 'handles initial positions', ->
			assert.equal 'foo', csv.read.qfield '"foo","bar","baz"'
		it 'handles in-between positions', ->
			assert.equal 'bar', csv.read.qfield '"foo","bar","baz"', 7, nil
		it 'handles final positions', ->
			assert.equal 'baz', csv.read.qfield '"foo","bar","baz"', 13, nil
		it 'handles empty fields', ->
			assert.equal '', csv.read.qfield '"foo","","bar"', 7, nil
		it 'handles escaped quotes', ->
			assert.equal 'a"b', csv.read.qfield '"a""b"'
	describe 'with consumer', ->
		it 'handles single characters', ->
			assert.equal 'foo', csv.read.qfield '"', 1, nil, iter 'foo","bar","baz"', '.'
		it 'handles single characters with escaped quotes', ->
			assert.equal 'fo\n"o', csv.read.qfield '', 1, nil, iter '"fo\n""o","bar","baz"', '.'

describe '#record parser', ->
	file = 'foo,bar,baz\nFoo,Bar,Baz\nFOO,BAR,BAZ'
	describe 'without consumer', ->
		it 'handles initial lines', ->
			assert.same {'foo', 'bar', 'baz'}, csv.read.record file
		it 'handles in-between lines', ->
			assert.same {'Foo', 'Bar', 'Baz'}, csv.read.record file, 13, nil
		it 'handles final lines', ->
			assert.same {'FOO', 'BAR', 'BAZ'}, csv.read.record file, 25, nil
	for name, pattern in pairs{character: ".", line: "[^\n]+", unaligned: "..?.?.?.?"}
		describe "with #{name} consumer", ->
			it 'handles empty current strings', ->
				assert.same {'foo', 'bar', 'baz'}, csv.read.record '', 1, nil, iter 'foo,bar,baz', pattern
			it 'handles initialized current strings', ->
				i = iter 'foo,bar,baz', pattern
				assert.same {'foo', 'bar', 'baz'}, csv.read.record i(), 1, nil, i

describe '#file parser', ->
	describe 'without consumer', ->
		it 'reads in a basic file', ->
			assert.same {{"foo", "bar"}, {"baz"}}, csv.read.file 'foo,bar\nbaz'
		it 'reads files with consumer', ->
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', 1, nil, iter '11,12\n21,22', "."
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', 1, nil, iter '11,12\n21,22', "..?"
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', 1, nil, iter '11,12\n21,22', "[^\n]+\n?"
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', 1, '\n;', iter '11;12\n21;22', "."
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', 1, '\n;', iter '11;12\n21;22', "..?"
			assert.same {{"11", "12"}, {"21", "22"}}, csv.read.file '', 1, '\n;', iter '11;12\n21;22', "[^\n]+\n?"
