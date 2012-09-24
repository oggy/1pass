{App} = require 'one_pass'

keychainPath = 'test/data/1Password.agilekeychain'

class StringStream
  constructor: ->
    @data = ''

  write: (data) ->
    @data += data

  contains: (pattern) ->
    if typeof(pattern) == 'string'
      @data.indexOf(pattern) != -1
    else
      pattern.test(@data)

class Prompter
  constructor: (@databasePassword, @databasePath) ->

  password: (prompt, callback) ->
    if @databasePassword
      callback(@databasePassword)
    else
      throw 'no password configured'

  prompt: (prompt, callback) ->
    if @databasePath
      callback(@databasePath)
    else
      throw 'no database path configured'

makeApp = (args, databasePassword, databasePath) ->
  output = new StringStream()
  error = new StringStream()
  prompter = new Prompter(databasePassword, databasePath)
  new App(['node', 'script'].concat(args), output, error, prompter)

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

  "App#run show with -r prints raw representations": (beforeExit, assert) ->
    app = makeApp(['-d', keychainPath, '-r', 'show', 'my-login'], 'master-password')
    app.run (status) ->
      assert.ok(app.output.contains('my-password'))
      assert.ok(!app.output.contains('Password:'))

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

  "App#run, when a database path is specified and does not exist, exits with an error": (beforeExit, assert) ->
    app = makeApp(['-d', 'invalid.agilekeychain', 'list'])
    app.run (status) ->
      assert.ok(app.error.contains("can't find keychain: invalid.agilekeychain"))
      assert.equal(status, 1)

  "App#run, when a database path is specified and exists runs the command": (beforeExit, assert) ->
    app = makeApp(['-d', 'test/data/1Password.agilekeychain', 'list'])
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.equal(status, 0)

  "App#run, when no database path is specified, can find one in the default paths": (beforeExit, assert) ->
    app = makeApp(['list'])
    app.defaultDatabasePaths = ['test/data/1Password.agilekeychain']
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.equal(status, 0)

  "App#run, when no database path is specified, and a valid path is given when prompted, runs the command": (beforeExit, assert) ->
    app = makeApp(['list'], null, 'test/data/1Password.agilekeychain')
    app.defaultDatabasePaths = ['invalid.agilekeychain']
    app.run (status) ->
      assert.ok(app.output.contains('my-login'))
      assert.equal(status, 0)

  "App#run, when no database path is specified, and an invalid path is given when prompted, exits with an error": (beforeExit, assert) ->
    app = makeApp(['list'], null, 'invalid-prompted.agilekeychain')
    app.defaultDatabasePaths = ['invalid-default.agilekeychain']
    app.run (status) ->
      assert.ok(app.error.contains(/can\'t find keychain:.*invalid-prompted.agilekeychain/))
      assert.equal(status, 1)
