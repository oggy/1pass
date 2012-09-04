{App} = require('one_pass')

module.exports =
  'App exits cleanly': (beforeExit, assert) ->
    assert.equal(0, new App().run())
