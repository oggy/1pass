util = require 'util'
fs = require 'fs'
pathlib = require 'path'
Commander = require 'commander'
Database = require './database'
PasswordServer = require './password_server'
Renderer = require './renderer'

class App
  constructor: (args, @output, @error, @prompter) ->
    @configuration = @parseArgs(args)
    @prompter ?= Commander
    @defaultDatabasePaths ?= [
      '~/Library/Application Support/1Password/1Password.agilekeychain'
      '~/Dropbox/1Password.agilekeychain'
    ]

  run: (done) ->
    @findDatabase (path) =>
      @databasePath = path
      if path
        @database = new Database(path)
        command = @configuration.args.shift()
        switch command
          when 'show', 'list'
            this[command](@configuration.args, done)
          else
            @show([command].concat(@configuration.args), done)
      else
        done(1)

  show: (args, done) ->
    @requirePassword done, =>
      items = @database.search(args[0])
      i = 0
      for item in items
        i += 1
        renderer = new Renderer(item)
        if @configuration.raw
          renderer.renderRaw(@output)
        else
          @output.write("#{i}. ")
          renderer.render(@output)
      done(0)

  list: (args, done) ->
    items = @database.search(args[0])
    for item in items
      @output.write((item.name ? '(unnamed)') + '\n')
    done(0)

  requirePassword: (done, callback) ->
    @getPasswordServer().get (password) =>
      if password and @database.unlock(password)
        callback(true)
      else
        @promptForPassword(done, callback)

  promptForPassword: (done, callback, attempt=1) ->
    @prompter.password 'Password: ', (password) =>
      if @database.unlock(password)
        @getPasswordServer().start password, @configuration.remember * 1000, ->
          callback(true)
      else
        if attempt == 3
          @error.write('Sorry.\n')
          done(1)
        else
          @error.write('Try again.\n')
          @promptForPassword(done, callback, attempt + 1)

  getPasswordServer: ->
    if !@passwordServer
      @passwordServer = new PasswordServer(@configuration.config, @configuration.data)
    @passwordServer

  parseArgs: (args) ->
    version = JSON.parse(fs.readFileSync(__dirname + '/../package.json')).version
    # Create a new Commander instance so tests don't share state.
    commander = new Commander.constructor()
      .version(version)
      .usage('[options] [ show | list ] [ QUERY ]')
      .description('1Password command line client.')
      .option('-d, --data <data>', 'path to keychain')
      .option('-c, --config <dir>', 'path to config dir (default: ~/.1pass)')
      .option('-r, --remember <secs>', 'remember password for this long (default: 5min)', Number, 300)
      .option('-R, --raw', 'show raw item data (for bug reports)')
      .parse(args)
    commander.config = @expandPath(commander.config or '~/.1pass')
    commander

  findDatabase: (callback) ->
    if (explicitPath = @configuration.data)
      if fs.existsSync(explicitPath)
        callback(explicitPath)
      else
        @error.write("can't find keychain: #{explicitPath}\n")
        callback(null)
    else
      for path in @defaultDatabasePaths
        path = @expandPath(path)
        if fs.existsSync(path)
          return callback(path)

      @error.write "Cannot find your keychain in the standard locations:\n\n"
      for path in @defaultDatabasePaths
        @error.write " * #{path}\n"
      @error.write "\nThis is typically a folder that ends in .agilekeychain.\n"

      @prompter.prompt "Where is your keychain? ", (response) =>
        path = @expandPath(response)
        if fs.existsSync(path)
          callback(path)
        else
          @error.write("can't find keychain: #{path}\n")
          callback(null)

  expandPath: (path) ->
    path = path.replace(/^~/, process.env.HOME)
    if path[0] != '/'
      path = process.cwd() + '/' + path
    pathlib.normalize(path)

module.exports = App
