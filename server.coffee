#!/usr/bin/env coffee

WebSocketServer = require('websocket').server
fs = require('fs')
http = require('http')
port = 8000

page = fs.readFileSync('index.html.gz')
httpCallback = (request, response) ->
  m = request.method
  if m in ['GET', 'HEAD']
    if request.url is '/'
      response.setHeader('Content-Encoding', 'gzip')
      response.write(page) if m is 'GET'
    else
      cmd = request.url.slice(1)
      response.write('OK') if m is 'GET'
      c.sendUTF(cmd) for c in wsServer.connections
      log('relayed: ' + cmd)
  else
    response.writeHead(501, 'Not Implemented')
  response.end()

httpServer = http.createServer(httpCallback)
httpServer.listen(port)

wsServer = new WebSocketServer(httpServer: httpServer, autoAcceptConnections: false)
log = (s) -> console.log "#{new Date()} - clients: #{wsServer.connections.length} - #{s}"

wsServer.on 'request', (request) ->
  if wsServer.connections.length > 1  # max connections
    log("rejected connection: client already connected")
    request.reject()
    return
  connection = request.accept(null, request.origin)
  log("connected: #{connection.remoteAddress}")
  connection.on 'close', (reasonCode, description) ->
    log("disconnected: #{connection.remoteAddress}")
