streamcsv = require 'streamcsv'

describe 'High-level records parser', ->
	it 'reads CSV files without header', ->
		for idx, record in streamcsv.records(io.open('spec/fixtures/basic.csv'))
			assert.equal 3, #record
	it 'reads CSV files with given string header', ->
		for idx, record in streamcsv.records(io.open('spec/fixtures/basic.csv'), header: 'a,b,c')
			assert.not.nil record.a
			assert.not.nil record.b
			assert.not.nil record.c
			assert.equal 3, #record[0]
	it 'reads CSV files with given table header', ->
		for idx, record in streamcsv.records(io.open('spec/fixtures/basic.csv'), header: {'a','b','c'})
			assert.not.nil record.a
			assert.not.nil record.b
			assert.not.nil record.c
			assert.equal 3, #record[0]
	it 'reads CSV files with builtin header', ->
		for idx, record in streamcsv.records(io.open('spec/fixtures/basic.csv'), header: true)
			assert.not.nil record.foo
			assert.not.nil record.bar
			assert.not.nil record.baz
			assert.equal 3, #record[0]
	describe 'with #weird delimiters', ->
		it 'reads CSV files without header', ->
			for idx, record in streamcsv.records(io.open('spec/fixtures/semicolon-pipe.csv'), rowsep: "|", colsep: ";")
				assert.equal 3, #record
		it 'reads CSV files with given string header', ->
			for idx, record in streamcsv.records(io.open('spec/fixtures/semicolon-pipe.csv'), header: 'a;b;c', rowsep: "|", colsep: ";")
				assert.not.nil record.a
				assert.not.nil record.b
				assert.not.nil record.c
				assert.equal 3, #record[0]
		it 'reads CSV files with given table header', ->
			for idx, record in streamcsv.records(io.open('spec/fixtures/semicolon-pipe.csv'), header: {'a','b','c'}, rowsep: "|", colsep: ";")
				assert.not.nil record.a
				assert.not.nil record.b
				assert.not.nil record.c
				assert.equal 3, #record[0]
		it 'reads CSV files with builtin header', ->
			for idx, record in streamcsv.records(io.open('spec/fixtures/semicolon-pipe.csv'), header: true, rowsep: "|", colsep: ";")
				assert.not.nil record.foo
				assert.not.nil record.bar
				assert.not.nil record.baz
				assert.equal 3, #record[0]
