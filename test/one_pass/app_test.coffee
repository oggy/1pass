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
    app = makeApp(['-d', keychainPath, 'show', 'my-login'], 'master-password')
    app.run (status) ->
      assert.equal(status, 0)

  "App#run show returns 1 if the password is incorrect": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'show', 'my-login'], 'wrong')
    app.run (status) ->
      assert.equal(status, 1)

  "App#run show prints the details of matched items": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'show', 'my-login'], 'master-password')
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.ok(app.output.contains('my-password'))

  "App#run list returns 0 without asking for a password": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'list', 'my-login'])
    app.run (status) ->
      assert.equal(status, 0)

  "App#run list prints the name of matched items, without details": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'list'])
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.ok(!app.output.contains('my-password'))

  "App#run list prints all items by default": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'list'])
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.ok(app.output.contains('my-social-security-number'))

  "App#run list filters items to those matching the argument, if any": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'list', 'my-login'])
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.ok(!app.output.contains('my-social-security-number'))

  "App#run defaults to running the show command": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, 'my-login'], 'master-password')
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.ok(app.output.contains('my-password'))
