PasswordServer = require './password_server'

process.on 'message', ({rcDir, databasePath, password, lifetime}) ->
  server = new PasswordServer(rcDir, databasePath)
  server._exec password, lifetime, ->
    process.send ready: true
