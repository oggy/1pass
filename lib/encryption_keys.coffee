{GibberishAES} = require './vendor'

class EncryptionKeys
  constructor: (data) ->
    @masterPassword = null
    @keys = {}
    for item in data.list
      if data[item.level] == item.identifier
        @keys[item.level] = new EncryptionKeys.Key(item)
    @keys

  unlock: (password) ->
    return false if !@keys.SL5
    success = @keys.SL5.unlock(password)
    @masterPassword = password if success
    success

  locked: ->
    !@masterPassword

  get: (securityLevel) ->
    throw 'database is locked' if @locked()
    key = @keys[securityLevel]
    return null if !key
    key.unlock(@masterPassword)
    key

class EncryptionKeys.Key
  constructor: (data) ->
    for name, value of data
      this[name] = value

  unlock: (password) ->
    iterations = Math.max(1000, parseInt(@iterations || 0, 10))
    decrypted = GibberishAES.decryptUsingPBKDF2(@data, password, iterations)
    return false if !decrypted

    verification = GibberishAES.decryptBase64UsingKey(@validation, GibberishAES.s2a(decrypted))
    success = verification == decrypted
    @value = decrypted if success
    success

module.exports = EncryptionKeys
