import field, record, file from require 'streamcsv.write'

describe 'Field writer', ->
	it "writes simple fields as is", ->
		assert.equal 'foobar', field 'foobar'
	it "converts numbers to strings", ->
		assert.equal '123', field 123
	it "converts booleans to strings", ->
		assert.same 'true', field true
		assert.same 'false', field false
	it "turns nil into an empty record", ->
		assert.equal '', field nil
	it "escapes separators", ->
		assert.equal '"foo\tbar"', field 'foo\tbar', '\t;'
		assert.equal '"foo;bar"', field 'foo;bar', '\t;'
	it "escapes initial quotes", ->
		assert.equal '"""foo"""', field '"foo"'
	it "doesn't escape other quotes", ->
		assert.equal 'foo"bar"', field 'foo"bar"'

describe 'Record writer', ->
	it "writes simple records", ->
		assert.equal 'foo,bar', record {'foo', 'bar'}
	it "respects the sep argument", ->
		assert.equal 'foo;bar', record {'foo', 'bar'}, nil, '\t;'
	it "respects headers", ->
		assert.equal '1,2', record {a: 1, b: 2}, {"a", "b"}
	it "uses headers over array records", ->
		assert.equal ',', record {1, 2}, {"a", "b"}
		assert.equal ';', record {1, 2}, "a;b", "\n;"

describe 'File writer', ->
	it "writes simple files", ->
		assert.equal 'foo,bar\nbaz', file {{'foo','bar'},{'baz'}}
	it "respects the separators argument", ->
		assert.equal 'foo;bar\tbaz', file {{'foo','bar'},{'baz'}}, nil, '\t;'
	it "prints and respects headers", ->
		assert.equal 'a,b\n1,2', file {{a: 1, b: 2}}, {"a", "b"}
