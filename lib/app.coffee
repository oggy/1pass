util = require 'util'
fs = require 'fs'
pathlib = require 'path'
Commander = require 'commander'
Database = require './database'
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
    @databasePath (path) =>
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
    @prompter.password 'Password: ', (password) =>
      if @database.unlock(password)
        callback(true)
      else
        @output.write('Try again.\n')
        done(1)

  parseArgs: (args) ->
    # Create a new Commander instance so tests don't share state.
    new Commander.constructor()
      .version('0.0.0')
      .usage('[options] [ show | list ] [ QUERY ]')
      .description('1Password command line client.')
      .option('-d, --data <data>', 'path to keychain')
      .option('-r, --raw', 'show raw item data (for bug reports)')
      .parse(args)

  databasePath: (callback) ->
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
          callback(response)
        else
          @error.write("can't find keychain: #{path}\n")
          callback(null)

  expandPath: (path) ->
    path = path.replace(/~/, process.env.HOME)
    if path[0] != '/'
      path = process.cwd() + '/' + path
    pathlib.normalize(path)

module.exports = App
