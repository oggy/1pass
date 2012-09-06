fs = require 'fs'
EncryptionKeys = require './encryption_keys'
Contents = require './contents'

readJSONFile = (path) ->
  buffer = fs.readFileSync(path)
  JSON.parse(buffer.toString())

class Database
  constructor: (root) ->
    expandPath = (baseName) -> root + '/data/default/' + baseName

    encryptionKeysData = readJSONFile(expandPath('encryptionKeys.js'))
    @encryptionKeys = new EncryptionKeys(encryptionKeysData)

    contentsData = readJSONFile(expandPath('contents.js'))
    fetcher = (uuid) -> readJSONFile(expandPath(uuid + '.1password'))
    @contents = new Contents(contentsData, fetcher)

  unlock: (password) ->
    @encryptionKeys.unlock(password)

  locked: ->
    @encryptionKeys.locked()

  search: (query) ->
    items = @contents.search(query)
    if !@locked()
      for item in items
        securityLevel = item.securityLevel()
        key = @encryptionKeys.get(securityLevel)
        item.unlock(key.value)
    items

module.exports = Database
