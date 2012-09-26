{GibberishAES} = require './vendor'

class Contents
  constructor: (data, fetcher) ->
    @items = (new Contents.Item(row, fetcher) for row in data)

  search: (query) ->
    matchers = if query then [@matchExact, @matchInclude, @matchFuzzy] else [-> true]
    for matcher in matchers
      matches = []
      for item in @items
        continue if item.trashed == 'Y'
        if matcher.call(this, query, item.name)
          matches.push(item)
      return matches if matches.length > 0
    []

  matchExact: (query, string) ->
    string.toLowerCase() == query.toLowerCase()

  matchInclude: (query, string) ->
    string.toLowerCase().indexOf(query.toLowerCase()) != -1

  matchFuzzy: (query, string) ->
    @matchFuzzyFrom(query.toLowerCase(), string.toLowerCase(), 0, 0)

  matchFuzzyFrom: (query, string, queryIndex, stringIndex) ->
    return true if queryIndex >= query.length
    i = string.indexOf(query.charAt(queryIndex), stringIndex)
    return false if i == -1
    @matchFuzzyFrom(query, string, queryIndex + 1, i + 1)

class Contents.Item
  constructor: (row, fetcher) ->
    @fetcher = fetcher
    [@uuid, @type, @name, @url, @timestamp, @folder, @strength, @trashed] = row

  unlock: (key) ->
    return true if @decrypted
    raw = GibberishAES.decryptBase64UsingKey(@detail().encrypted, GibberishAES.s2a(key))
    @decrypted = JSON.parse(decodeURIComponent(escape(raw)))

  locked: ->
    !@decrypted

  securityLevel: ->
    @detail().openContents.securityLevel || 'SL5'

  detail: ->
    return @_detail if @_detail
    @_detail = @fetcher(@uuid)

module.exports = Contents
