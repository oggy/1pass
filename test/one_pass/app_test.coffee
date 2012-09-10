{App} = require 'one_pass'

keychainPath = 'test/data/1Password.agilekeychain'

class StringStream
  constructor: ->
    @data = ''

  write: (data) ->
    @data += data

  contains: (string) ->
    @data.indexOf(string) != -1

makeApp = (args, password) ->
  output = new StringStream()
  error = new StringStream()
  app = new App(['node', 'script'].concat(args), output, error)
  if (password)
    app.askPassword = (c) -> c(password)
  else
    app.askPassword = (c) -> throw 'unexpected password prompt'
  app

module.exports =
  "App#run show returns 0 if the password is correct": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'show', 'Login'], 'master-password')
    app.run (status) ->
      assert.equal(status, 0)

  "App#run show returns 1 if the password is incorrect": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'show', 'Login'], 'wrong')
    app.run (status) ->
      assert.equal(status, 1)

  "App#run show prints the details of matched items": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'show', 'Login'], 'master-password')
    app.run (status) ->
      assert.ok(app.output.contains("Login"))
      assert.ok(app.output.contains("password"))

  "App#run list returns 0 without asking for a password": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'list', 'Login'])
    app.run (status) ->
      assert.equal(status, 0)

  "App#run list prints the name of matched items, and not details": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'list', 'Login'])
    app.run (status) ->
      assert.ok(app.output.contains("Login"))
      assert.ok(!app.output.contains("password"))

  "App#run defaults to running the show command": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'Login'], 'master-password')
    app.run (status) ->
      assert.ok(app.output.contains("Login"))
      assert.ok(app.output.contains("password"))
