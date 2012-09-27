fs = require 'fs'
assert = require 'assert'
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

describe "Renderer", ->
  describe '#renderRaw', ->
    it "renders the raw item data", ->
      item = db.search('my-login')[0]
      renderer = new Renderer(item)
      stream = new StringStream()
      renderer.renderRaw(stream)

      assert.ok(stream.contains(/value.*my-password/))

  describe '#render', ->
    it "renders the raw item data for unknown types", ->
      source = db.search('my-login')[0]
      item = {}
      for name, value of source
        item[name] = if name == 'type' then 'unknown' else value
      renderer = new Renderer(item)
      stream = new StringStream()
      renderer.render(stream)

      assert.ok(stream.contains(/value.*my-password/))

    it "renders a Login item correctly", ->
      assert.equal(render('my-login'), RENDERINGS['my-login'])

    it "renders an Amazon Web Service item correctly", ->
      assert.equal(render('my-amazon-web-service'), RENDERINGS['my-amazon-web-service'])

    it "renders a Database item correctly", ->
      assert.equal(render('my-database'), RENDERINGS['my-database'])

    it "renders an Email Account item correctly", ->
      assert.equal(render('my-email-account'), RENDERINGS['my-email-account'])

    it "renders an FTP Account item correctly", ->
      assert.equal(render('my-ftp-account'), RENDERINGS['my-ftp-account'])

    it "renders a Generic Account item correctly", ->
      assert.equal(render('my-generic-account'), RENDERINGS['my-generic-account'])

    it "renders an Instant Messenger item correctly", ->
      assert.equal(render('my-instant-messenger'), RENDERINGS['my-instant-messenger'])

    it "renders an Internet Provider item correctly", ->
      assert.equal(render('my-internet-provider'), RENDERINGS['my-internet-provider'])

    it "renders a MobileMe item correctly", ->
      assert.equal(render('my-mobile-me'), RENDERINGS['my-mobile-me'])

    it "renders a Server item correctly", ->
      assert.equal(render('my-server'), RENDERINGS['my-server'])

    it "renders a Wireless Router item correctly", ->
      assert.equal(render('my-wireless-router'), RENDERINGS['my-wireless-router'])

    it "renders an iTunes item correctly", ->
      assert.equal(render('my-itunes'), RENDERINGS['my-itunes'])

    it "renders an Identity item correctly", ->
      assert.equal(render('my-identity'), RENDERINGS['my-identity'])

    it "renders a Secure Note item correctly", ->
      assert.equal(render('my-secure-note'), RENDERINGS['my-secure-note'])

    it "renders a Software item correctly", ->
      assert.equal(render('my-software'), RENDERINGS['my-software'])

    it "renders a Bank Account item correctly", ->
      assert.equal(render('my-bank-account'), RENDERINGS['my-bank-account'])

    it "renders a Credit Card item correctly", ->
      assert.equal(render('my-credit-card'), RENDERINGS['my-credit-card'])

    it "renders a Drivers License item correctly", ->
      assert.equal(render('my-drivers-license'), RENDERINGS['my-drivers-license'])

    it "renders a Hunting License item correctly", ->
      assert.equal(render('my-hunting-license'), RENDERINGS['my-hunting-license'])

    it "renders a Membership item correctly", ->
      assert.equal(render('my-membership'), RENDERINGS['my-membership'])

    it "renders a Passport item correctly", ->
      assert.equal(render('my-passport'), RENDERINGS['my-passport'])

    it "renders a Reward Program item correctly", ->
      assert.equal(render('my-reward-program'), RENDERINGS['my-reward-program'])

    it "renders a Social Security Number item correctly", ->
      assert.equal(render('my-social-security-number'), RENDERINGS['my-social-security-number'])

    it "renders a Password item correctly", ->
      assert.equal(render('my-password'), RENDERINGS['my-password'])

    it "renders a minimal Login item correctly", ->
      assert.equal(render('my-minimal-login'), RENDERINGS['my-minimal-login'])
