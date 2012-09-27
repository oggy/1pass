fs = require 'fs'
assert = require 'assert'
{Contents} = require '..'

makeItem = (attributes) ->
  [
    attributes.uuid ? '00000000000000000000000000000000'
    attributes.type ? 'webforms.WebForm'
    attributes.name ? 'name'
    attributes.url ? 'http://example.com'
    attributes.date ? 1234567890
    attributes.folder ? ''
    attributes.passwordStrength ? 0
    attributes.trashed ? 'N'
  ]

searchItems = [
  makeItem(uuid: '0', name: 'Bank of Foo')
  makeItem(uuid: '1', name: 'bank of foo')
  makeItem(uuid: '2', name: 'FOOBAR')
  makeItem(uuid: '3', name: 'foobar')
  makeItem(uuid: '4', name: 'Bank of Bar')
  makeItem(uuid: '5', name: 'bank of bar')
]

describe 'Contents', ->
  describe '#search', ->
    it "without a key returns all items", ->
      contents = new Contents(searchItems)
      result = contents.search()
      assert.deepEqual((item.uuid for item in result), ['0', '1', '2', '3', '4', '5'])

    it "returns items whose name is exactly the key case-insensitively, if any", ->
      contents = new Contents(searchItems)
      result = contents.search('Bank of Foo')
      assert.deepEqual((item.uuid for item in result), ['0', '1'])

    it "otherwise returns items whose name contains the key case-insensitively, if any", ->
      contents = new Contents(searchItems)
      result = contents.search('oba')
      assert.deepEqual((item.uuid for item in result), ['2', '3'])

    it "otherwise returns items whose name fuzzy-matches the key case-insensitively, if any", ->
      contents = new Contents(searchItems)
      result = contents.search('bof')
      assert.deepEqual((item.uuid for item in result), ['0', '1', '4', '5'])

    it "otherwise returns an empty array", ->
      contents = new Contents(searchItems)
      result = contents.search('xyz')
      assert.deepEqual(result, [])

    it "does not return trashed items", ->
      items = [
        makeItem(uuid: '0', name: 'a', trashed: 'Y')
        makeItem(uuid: '1', name: 'a', trashed: 'N')
      ]
      contents = new Contents(items)
      result = contents.search('a')
      assert.deepEqual((item.uuid for item in result), ['1'])

  describe '.Item', ->
    describe '#securityLevel', ->
      it "is as specified in the openContents if present", ->
        data = {openContents: {securityLevel: 'SL3'}}
        item = new Contents.Item([], -> data)
        assert.equal(item.securityLevel(), 'SL3')

      it "is SL5 if the openContents does not specify a security level", ->
        data = {openContents: {}}
        item = new Contents.Item([], -> data)
        assert.equal(item.securityLevel(), 'SL5')
