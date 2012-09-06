fs = require 'fs'
{Contents} = require 'one_pass'

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

module.exports =
  "Contents#search returns items whose name is exactly the key case-insensitively, if any": (beforeExit, assert) ->
    contents = new Contents(searchItems)
    result = contents.search('Bank of Foo')
    assert.deepEqual((item.uuid for item in result), ['0', '1'])

  "Contents#search otherwise returns items whose name contains the key case-insensitively, if any": (beforeExit, assert) ->
    contents = new Contents(searchItems)
    result = contents.search('oba')
    assert.deepEqual((item.uuid for item in result), ['2', '3'])

  "Contents#search otherwise returns items whose name fuzzy-matches the key case-insensitively, if any": (beforeExit, assert) ->
    contents = new Contents(searchItems)
    result = contents.search('bof')
    assert.deepEqual((item.uuid for item in result), ['0', '1', '4', '5'])

  "Contents#search otherwise returns an empty array": (beforeExit, assert) ->
    contents = new Contents(searchItems)
    result = contents.search('xyz')
    assert.deepEqual(result, [])

  "Contents#search does not return trashed items": (beforeExit, assert) ->
    items = [
      makeItem(uuid: '0', name: 'a', trashed: 'Y')
      makeItem(uuid: '1', name: 'a', trashed: 'N')
    ]
    contents = new Contents(items)
    result = contents.search('a')
    assert.deepEqual((item.uuid for item in result), ['1'])

  "Contents.Item#securityLevel is as specified in the openContents if present": (beforeExit, assert) ->
    data = {openContents: {securityLevel: 'SL3'}}
    item = new Contents.Item([], -> data)
    assert.equal(item.securityLevel(), 'SL3')

  "Contents.Item#securityLevel is SL5 if the openContents does not specify a security level": (beforeExit, assert) ->
    data = {openContents: {}}
    item = new Contents.Item([], -> data)
    assert.equal(item.securityLevel(), 'SL5')
