fs = require 'fs'
{Database,Renderer} = require '..'

loadRenderings = ->
  text = fs.readFileSync('test/data/renderings.txt').toString()
  segments = text.split(/(?:^|\n\n)## (.*)\n\n/)
  i = 1
  renderings = {}
  while i < segments.length
    name = segments[i++]
    rendering = segments[i++]
    rendering = "#{rendering}\n" if !/\n$/.test(rendering)
    renderings[name] = rendering
  renderings

RENDERINGS = loadRenderings()

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

db = new Database('test/data/1Password.agilekeychain')
db.unlock('master-password')

render = (name, assert) ->
  items = db.search(name)
  if items.length != 1
    throw "#{items.length} matches for #{name}, expected 1"

  renderer = new Renderer(items[0])
  stream = new StringStream()
  renderer.render(stream)

  stream.data

module.exports =
  'Renderer#renderRaw renders the raw item data': (beforeExit, assert) ->
    item = db.search('my-login')[0]
    renderer = new Renderer(item)
    stream = new StringStream()
    renderer.renderRaw(stream)

    assert.ok(stream.contains(/value.*my-password/))

  'Renderer#render renders the raw item data for unknown types': (beforeExit, assert) ->
    source = db.search('my-login')[0]
    item = {}
    for name, value of source
      item[name] = if name == 'type' then 'unknown' else value
    renderer = new Renderer(item)
    stream = new StringStream()
    renderer.render(stream)

    assert.ok(stream.contains(/value.*my-password/))

  'Renderer#render renders a Login item correctly': (beforeExit, assert) ->
    assert.equal(render('my-login'), RENDERINGS['my-login'])

  'Renderer#render renders an Amazon Web Service item correctly': (beforeExit, assert) ->
    assert.equal(render('my-amazon-web-service'), RENDERINGS['my-amazon-web-service'])

  'Renderer#render renders a Database item correctly': (beforeExit, assert) ->
    assert.equal(render('my-database'), RENDERINGS['my-database'])

  'Renderer#render renders an Email Account item correctly': (beforeExit, assert) ->
    assert.equal(render('my-email-account'), RENDERINGS['my-email-account'])

  'Renderer#render renders an FTP Account item correctly': (beforeExit, assert) ->
    assert.equal(render('my-ftp-account'), RENDERINGS['my-ftp-account'])

  'Renderer#render renders a Generic Account item correctly': (beforeExit, assert) ->
    assert.equal(render('my-generic-account'), RENDERINGS['my-generic-account'])

  'Renderer#render renders an Instant Messenger item correctly': (beforeExit, assert) ->
    assert.equal(render('my-instant-messenger'), RENDERINGS['my-instant-messenger'])

  'Renderer#render renders an Internet Provider item correctly': (beforeExit, assert) ->
    assert.equal(render('my-internet-provider'), RENDERINGS['my-internet-provider'])

  'Renderer#render renders a MobileMe item correctly': (beforeExit, assert) ->
    assert.equal(render('my-mobile-me'), RENDERINGS['my-mobile-me'])

  'Renderer#render renders a Server item correctly': (beforeExit, assert) ->
    assert.equal(render('my-server'), RENDERINGS['my-server'])

  'Renderer#render renders a Wireless Router item correctly': (beforeExit, assert) ->
    assert.equal(render('my-wireless-router'), RENDERINGS['my-wireless-router'])

  'Renderer#render renders an iTunes item correctly': (beforeExit, assert) ->
    assert.equal(render('my-itunes'), RENDERINGS['my-itunes'])

  'Renderer#render renders an Identity item correctly': (beforeExit, assert) ->
    assert.equal(render('my-identity'), RENDERINGS['my-identity'])

  'Renderer#render renders a Secure Note item correctly': (beforeExit, assert) ->
    assert.equal(render('my-secure-note'), RENDERINGS['my-secure-note'])

  'Renderer#render renders a Software item correctly': (beforeExit, assert) ->
    assert.equal(render('my-software'), RENDERINGS['my-software'])

  'Renderer#render renders a Bank Account item correctly': (beforeExit, assert) ->
    assert.equal(render('my-bank-account'), RENDERINGS['my-bank-account'])

  'Renderer#render renders a Credit Card item correctly': (beforeExit, assert) ->
    assert.equal(render('my-credit-card'), RENDERINGS['my-credit-card'])

  'Renderer#render renders a Drivers License item correctly': (beforeExit, assert) ->
    assert.equal(render('my-drivers-license'), RENDERINGS['my-drivers-license'])

  'Renderer#render renders a Hunting License item correctly': (beforeExit, assert) ->
    assert.equal(render('my-hunting-license'), RENDERINGS['my-hunting-license'])

  'Renderer#render renders a Membership item correctly': (beforeExit, assert) ->
    assert.equal(render('my-membership'), RENDERINGS['my-membership'])

  'Renderer#render renders a Passport item correctly': (beforeExit, assert) ->
    assert.equal(render('my-passport'), RENDERINGS['my-passport'])

  'Renderer#render renders a Reward Program item correctly': (beforeExit, assert) ->
    assert.equal(render('my-reward-program'), RENDERINGS['my-reward-program'])

  'Renderer#render renders a Social Security Number item correctly': (beforeExit, assert) ->
    assert.equal(render('my-social-security-number'), RENDERINGS['my-social-security-number'])

  'Renderer#render renders a Password item correctly': (beforeExit, assert) ->
    assert.equal(render('my-password'), RENDERINGS['my-password'])

  'Renderer#render renders a minimal Login item correctly': (beforeExit, assert) ->
    assert.equal(render('my-minimal-login'), RENDERINGS['my-minimal-login'])
