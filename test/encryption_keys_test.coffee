fs = require 'fs'
assert = require 'assert'
{EncryptionKeys} = require '..'

describe 'EncryptionKeys', ->
  beforeEach ->
    data = JSON.parse(fs.readFileSync('test/data/1Password.agilekeychain/data/default/encryptionKeys.js').toString())
    @encryptionKeys = new EncryptionKeys(data)

  describe '#constructor', ->
    it "creates a locked database", ->
      assert.equal(@encryptionKeys.locked(), true)

  describe '#unlock', ->
    it "returns true and unlocks the keys if the given password is correct", ->
      result = @encryptionKeys.unlock('master-password')
      assert.equal(result, true)
      assert.equal(@encryptionKeys.locked(), false)

    it "returns false and does not unlock the keys if the given password is incorrect", ->
      result = @encryptionKeys.unlock('wrong')
      assert.equal(result, false)
      assert.equal(@encryptionKeys.locked(), true)

  describe '#get', ->
    describe "when unlocked", ->
      beforeEach ->
        assert.equal(@encryptionKeys.unlock('master-password'), true)

      it "returns the unlocked key for the given security level", ->
        key = @encryptionKeys.get('SL5')
        assert.ok(key)
        assert.ok(key.value)

      it "returns null if the given key does not exist", ->
        assert.equal(@encryptionKeys.get('missing-key'), null)

    describe "when locked", ->
      it "when locked throws an error", ->
        assert.throws((-> @encryptionKeys.get('missing-key')), 'database is locked')
