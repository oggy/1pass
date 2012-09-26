fs = require 'fs'
{EncryptionKeys} = require '..'

data = JSON.parse(fs.readFileSync('test/data/1Password.agilekeychain/data/default/encryptionKeys.js').toString())

module.exports =
  "EncryptionKeys#constructor creates a locked database": (beforeExit, assert) ->
    encryptionKeys = new EncryptionKeys(data)
    assert.equal(encryptionKeys.locked(), true)

  "EncryptionKeys#unlock returns true and unlocks the keys if the given password is correct": (beforeExit, assert) ->
    encryptionKeys = new EncryptionKeys(data)
    result = encryptionKeys.unlock('master-password')
    assert.equal(result, true)
    assert.equal(encryptionKeys.locked(), false)

  "EncryptionKeys#unlock returns false and does not unlock the keys if the given password is incorrect": (beforeExit, assert) ->
    encryptionKeys = new EncryptionKeys(data)
    result = encryptionKeys.unlock('wrong')
    assert.equal(result, false)
    assert.equal(encryptionKeys.locked(), true)

  "EncryptionKeys#get when unlocked returns the unlocked key for the given security level": (beforeExit, assert) ->
    encryptionKeys = new EncryptionKeys(data)
    assert.equal(encryptionKeys.unlock('master-password'), true)
    key = encryptionKeys.get('SL5')
    assert.ok(key)
    assert.ok(key.value)

  "EncryptionKeys#get when unlocked returns null if the given key does not exist": (beforeExit, assert) ->
    encryptionKeys = new EncryptionKeys(data)
    assert.equal(encryptionKeys.unlock('master-password'), true)
    assert.equal(encryptionKeys.get('missing-key'), null)

  "EncryptionKeys#get when locked throws an error": (beforeExit, assert) ->
    encryptionKeys = new EncryptionKeys(data)
    assert.throws((-> encryptionKeys.get('missing-key')), 'database is locked')
