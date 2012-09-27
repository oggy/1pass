assert = require 'assert'
{App} = require '..'

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
  constructor: (@databasePasswords, @databasePath=[]) ->

  password: (prompt, callback) ->
    password = @databasePasswords.shift()
    if password
      callback(password)
    else
      throw 'no more passwords configured'

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

describe 'App', ->
  describe '#run', ->
    describe 'show', ->
      it "returns 0 if the password is correct", (done) ->
        app = makeApp(['-d', keychainPath, 'show', 'my-login'], ['master-password'])
        app.run (status) ->
          assert.equal(status, 0)
          done()

      it "returns 0 if the 3rd password attempt is correct", (done) ->
        app = makeApp(['-d', keychainPath, 'show', 'my-login'], ['wrong', 'wrong', 'master-password'])
        app.run (status) ->
          assert.equal(status, 0)
          done()

      it "returns 1 if 3 password attempts are incorrect", (done) ->
        app = makeApp(['-d', keychainPath, 'show', 'my-login'], ['wrong', 'wrong', 'wrong'])
        app.run (status) ->
          assert.equal(status, 1)
          done()

      it "prints the details of matched items", (done) ->
        app = makeApp(['-d', keychainPath, 'show', 'my-login'], ['master-password'])
        app.run (status) ->
          assert.ok(app.output.contains('my-login'))
          assert.ok(app.output.contains('my-username'))
          done()

      it "prints raw representations with -r", (done) ->
        app = makeApp(['-d', keychainPath, '-r', 'show', 'my-login'], ['master-password'])
        app.run (status) ->
          assert.ok(app.output.contains('my-username'))
          assert.ok(!app.output.contains('Username:'))
          done()

    describe 'list', ->
      it "returns 0 without asking for a password", (done) ->
        app = makeApp(['-d', keychainPath, 'list', 'my-login'])
        app.run (status) ->
          assert.equal(status, 0)
          done()

      it "prints the name of matched items, without details", (done) ->
        app = makeApp(['-d', keychainPath, 'list'])
        app.run (status) ->
          assert.ok(app.output.contains('my-login'))
          assert.ok(!app.output.contains('my-username'))
          done()

      it "prints all items by default", (done) ->
        app = makeApp(['-d', keychainPath, 'list'])
        app.run (status) ->
          assert.ok(app.output.contains('my-login'))
          assert.ok(app.output.contains('my-social-security-number'))
          done()

      it "filters items to those matching the argument, if any", (done) ->
        app = makeApp(['-d', keychainPath, 'list', 'my-login'])
        app.run (status) ->
          assert.ok(app.output.contains('my-login'))
          assert.ok(!app.output.contains('my-social-security-number'))
          done()

    it "defaults to running the show command", (done) ->
      app = makeApp(['-d', keychainPath, 'my-login'], ['master-password'])
      app.run (status) ->
        assert.ok(app.output.contains('my-login'))
        assert.ok(app.output.contains('my-username'))
        done()

    describe "when a database path is specified and does not exist", ->
      beforeEach ->
        @app = makeApp(['-d', 'invalid.agilekeychain', 'list'])

      it "exits with an error", (done) ->
        @app.run (status) =>
          assert.ok(@app.error.contains("can't find keychain: invalid.agilekeychain"))
          assert.equal(status, 1)
          done()

    describe "when a database path is specified and exists", ->
      beforeEach ->
        @app = makeApp(['-d', 'test/data/1Password.agilekeychain', 'list'])

      it "runs the command", (done) ->
        @app.run (status) =>
          assert.ok(@app.output.contains('my-login'))
          assert.equal(status, 0)
          done()

    describe "when no database path is specified", ->
      beforeEach ->
        @app = makeApp(['list'])

      it "can find one in the default paths", (done) ->
        @app.defaultDatabasePaths = ['test/data/1Password.agilekeychain']
        @app.run (status) =>
          assert.ok(@app.output.contains('my-login'))
          assert.equal(status, 0)
          done()

    describe "when no database path is specified and a valid path is given when prompted", ->
      beforeEach ->
        @app = makeApp(['list'], null, 'test/data/1Password.agilekeychain')

      it "runs the command", (done) ->
        @app.defaultDatabasePaths = ['invalid.agilekeychain']
        @app.run (status) =>
          assert.ok(@app.output.contains('my-login'))
          assert.equal(status, 0)
          done()

    describe "when no database path is specified, and an invalid path is given when prompted", ->
      beforeEach ->
        @app = makeApp(['list'], null, 'invalid-prompted.agilekeychain')

      it "exits with an error", (done) ->
        @app.defaultDatabasePaths = ['invalid-default.agilekeychain']
        @app.run (status) =>
          assert.ok(@app.error.contains(/can\'t find keychain:.*invalid-prompted.agilekeychain/))
          assert.equal(status, 1)
          done()
