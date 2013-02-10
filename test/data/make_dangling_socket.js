var fs = require('fs');
var path = require('path');
var net = require('net');

function mkDirs(dir) {
  if (!fs.existsSync(dir)) {
    mkDirs(path.dirname(dir));
    fs.mkdirSync(dir);
  }
}

process.on('message', function(data) {
  var server = net.createServer();
  mkDirs(path.dirname(data.path));
  server.listen(data.path, function() {
    setTimeout(function() { process.kill(process.pid) });
  });
});
