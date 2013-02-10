assert = require 'assert'
path = require 'path'
fs = require 'fs'
child_process = require 'child_process'

{PasswordServer} = require '..'

TMP = "#{__dirname}/tmp"
TEST_TMP = "#{TMP}/password_server"
testId = 0

describe 'PasswordServer', ->
  beforeEach ->
    @testId = (testId += 1)
    @rcDir = "#{TEST_TMP}/rc.#{@testId}"
    @pids = []

  afterEach (done) ->
    for pid in @pids
      try
        process.kill(pid, 'SIGKILL')
      catch error
        throw error if error.code != 'ESRCH'
    done()

  after (done) ->
    child_process.exec "rm -rf \"#{TEST_TMP}\"", done

  describe "get", ->
    it "returns the password served by the server", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      server.start 'pass', 60000, (pid) =>
        @pids.push(pid)
        server.get (pass) ->
          assert.equal(pass, 'pass')
          done()

    it "handles nested database paths", (done) ->
      server = new PasswordServer(@rcDir, '/path/to/db')
      server.start 'pass', 60000, (pid) =>
        @pids.push(pid)
        server.get (pass) ->
          assert.equal(pass, 'pass')
          done()

    it "supports concurrent servers for different databases", (done) ->
      server1 = new PasswordServer(@rcDir, '/1')
      server2 = new PasswordServer(@rcDir, '/2')
      server1.start 'pass1', 60000, (pid1) =>
        @pids.push(pid1)
        server2.start 'pass2', 60000, (pid2) =>
          @pids.push(pid2)

          counter = 0
          server1.get (pass) ->
            assert.equal(pass, 'pass1')
            if (counter += 1) == 2
              done()
          server2.get (pass) ->
            assert.equal(pass, 'pass2')
            if (counter += 1) == 2
              done()

    it "passes null to the callback if the server is not running", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      server.get (pass) ->
        assert.equal(pass, null)
        done()

    it "passes null to the callback if there is nothing listening on the socket", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      child = child_process.fork(__dirname + '/data/make_dangling_socket.js')
      child.send path: server.socketPath
      child.on 'exit', =>
        assert fs.existsSync(server.socketPath)
        server.get (pass) ->
          assert.equal(pass, null)
          done()

  describe "start", ->
    it "sets secure permissions on the socket", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      server.start 'pass', 60000, (pid) =>
        @pids.push(pid)
        mode = fs.statSync(server.socketPath).mode
        assert.equal(mode & 0o777, 0o600)
        done()

    it "only lives for the given lifetime", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      server.start 'pass', 1, (pid) =>
        @pids.push(pid)
        setTimeout (->
          server.get (pass) ->
            assert.equal(pass, null)
            done()
        ), 5

    it "deletes an existing socket if there's nothing listening on it", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      child = child_process.fork(__dirname + '/data/make_dangling_socket.js')
      child.send path: server.socketPath
      child.on 'exit', =>
        assert fs.existsSync(server.socketPath)
        server.start 'pass', 60000, (pid) =>
          @pids.push(pid)
          server.get (pass) ->
            assert.equal(pass, 'pass')
            done()

    it "shuts down an existing server if there is one", (done) ->
      server1 = new PasswordServer(@rcDir, '/db')
      server2 = new PasswordServer(@rcDir, '/db')
      server1.start 'pass1', 60000, (pid1) =>
        @pids.push(pid1)
        server2.start 'pass2', 60000, (pid2) =>
          @pids.push(pid2)
          server1.get (pass) ->
            assert.equal(pass, 'pass2')
            done()

  describe "stop", ->
    it "shuts down an existing server if there is one", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      server.start 'pass1', 60000, (pid) =>
        @pids.push(pid)
        server.stop =>
          assert !fs.existsSync(server.socketPath)
          done()

    it "calls the callback if the server is not running", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      server.stop ->
        done()

    it "calls the callback if there is nothing listening on the socket", (done) ->
      server = new PasswordServer(@rcDir, '/db')
      child = child_process.fork(__dirname + '/data/make_dangling_socket.js')
      child.send path: server.socketPath
      child.on 'exit', ->
        assert fs.existsSync(server.socketPath)
        server.stop ->
          done()
