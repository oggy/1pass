Vendor = require './lib/vendor'
Vendor.GibberishAES.size(128)

module.exports =
  App: require './lib/app'
  Contents: require './lib/contents'
  Database: require './lib/database'
  EncryptionKeys: require './lib/encryption_keys'
  Renderer: require './lib/renderer'

for name, value of Vendor
  module.exports[name] = value
