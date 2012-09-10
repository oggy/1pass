{Database} = require 'one_pass'

module.exports =
  'Database#unlock returns true and unlocks the database if the given password is correct': (beforeExit, assert) ->
    db = new Database('test/data/1Password.agilekeychain')
    result = db.unlock('master-password')
    assert.equal(result, true)
    assert.equal(db.locked(), false)

  'Database#unlock returns false and does not unlock the database if the given password is incorrect': (beforeExit, assert) ->
    db = new Database('test/data/1Password.agilekeychain')
    result = db.unlock('wrong')
    assert.equal(result, false)
    assert.equal(db.locked(), true)

  'Database#search returns matching items': (beforeExit, assert) ->
    db = new Database('test/data/1Password.agilekeychain')
    items = db.search('my-minimal-login')
    assert.deepEqual((item.name for item in items), ['my-minimal-login'])

  'Database#search unlocks the items if the database is unlocked': (beforeExit, assert) ->
    db = new Database('test/data/1Password.agilekeychain')
    assert.equal(db.unlock('master-password'), true)
    items = db.search('my-minimal-login')
    assert.equal(items[0].locked(), false)

  'Database#search does not unlock the items if the database is still locked': (beforeExit, assert) ->
    db = new Database('test/data/1Password.agilekeychain')
    items = db.search('my-minimal-login')
    assert.equal(items[0].locked(), true)
