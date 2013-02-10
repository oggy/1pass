fs = require 'fs'
path = require 'path'
net = require 'net'
child_process = require 'child_process'

class PasswordServer
  constructor: (@rcDir, @databasePath) ->
    @socketPath = (rcDir + '/sockets/' + databasePath).replace(/\/+/g, '/')

  start: (password, lifetime, callback) ->
    @stop =>
      child = child_process.fork(__dirname + '/password_server_child')
      child.on 'message', ->
        callback(child.pid)
      child.send
        rcDir: @rcDir
        databasePath: @databasePath
        password: password
        lifetime: lifetime

  stop: (callback) ->
    buffer = []
    fs.exists @socketPath, (exists) =>
      return callback() if !exists
      @_read (pid, pass) =>
        if !pid
          fs.unlink @socketPath, callback
        else
          @_killAndWait pid, 'SIGTERM', 2000, (result) =>
            if result
              callback() if callback
            else
              @_killAndWait pid, 'SIGKILL', 2000, =>
                callback() if callback

  get: (callback) ->
    @_read (pid, pass) ->
      callback(pass)

  _makeDirs: (dir) ->
    unless fs.existsSync(dir)
      @_makeDirs path.dirname(dir)
      fs.mkdirSync(dir)

  _exec: (password, lifetime, readyCallback) ->
    cleanUp = =>
      fs.unlinkSync(@socketPath) if fs.existsSync(@socketPath)
      process.exit()
    process.on 'SIGINT' , cleanUp
    process.on 'SIGTERM', cleanUp
    process.on 'SIGALRM', cleanUp

    server = net.createServer (socket) =>
      socket.end("#{process.pid}\n#{password}")
    server.on 'close', cleanUp
    @_makeDirs path.dirname(@socketPath)
    setTimeout (-> process.kill(process.pid, 'SIGALRM')), lifetime
    server.listen @socketPath, =>
      fs.chmodSync(@socketPath, 0o600)
      readyCallback()

  _read: (callback) ->
    buffer = []
    socket = new net.Socket(type: 'unix')
    socket.on 'error', ->  # don't throw error if connect fails
    socket.on 'data', (data) -> buffer.push data
    socket.on 'close', ->
      [pid, pass] = buffer.join('').split(/\n/)
      callback(pid or null, pass or null)
    socket.connect path: @socketPath, ->
      socket.end()

  _killAndWait: (pid, signal, timeout, callback) ->
    return if !pid
    process.kill(pid, signal)
    @_waitFor
      timeout: timeout
      condition: (done) =>
        fs.exists @socketPath, (exists) -> done !exists
      complete: callback

  _waitFor: ({timeout, condition, complete}) ->
    condition (result) =>
      if result
        complete true
      else
        if timeout <= 0
          complete false
        else
          sleep = 100
          setTimeout (=>
            @_waitFor
              timeout: timeout - sleep
              condition: condition
              complete: complete
          ), sleep

module.exports = PasswordServer
