assert = require 'assert'
{Database} = require '..'

describe 'Database', ->
  beforeEach ->
    @db = new Database('test/data/1Password.agilekeychain')

  describe '#unlock', ->
    it "returns true and unlocks the database if the given password is correct", ->
      result = @db.unlock('master-password')
      assert.equal(result, true)
      assert.equal(@db.locked(), false)

    it "returns false and does not unlock the database if the given password is incorrect", ->
      result = @db.unlock('wrong')
      assert.equal(result, false)
      assert.equal(@db.locked(), true)

  describe '#search', ->
    it "returns matching items", ->
      items = @db.search('my-minimal-login')
      assert.deepEqual((item.name for item in items), ['my-minimal-login'])

    it "unlocks the items if the database is unlocked", ->
      assert.equal(@db.unlock('master-password'), true)
      items = @db.search('my-minimal-login')
      assert.equal(items[0].locked(), false)

    it "does not unlock the items if the database is still locked", ->
      items = @db.search('my-minimal-login')
      assert.equal(items[0].locked(), true)
