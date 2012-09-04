# Description:
#   A simple interaction with the built in HTTP Daemon
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /hubot/version - GET
#   /hubot/ping - POST
#   /hubot/time - GET
#   /hubot/info - INFO

spawn = require('child_process').spawn

module.exports = (robot) ->

  robot.router.get "/hubot/version", (req, res) ->
    res.end robot.version

  robot.router.post "/hubot/ping", (req, res) ->
    res.end "PONG"

  robot.router.get "/hubot/time", (req, res) ->
    res.end "Server time is: #{new Date()}"

  robot.router.get "/hubot/info", (req, res) ->
    child = spawn('/bin/sh', ['-c', "echo I\\'m $LOGNAME@$(hostname):$(pwd) \\($(git rev-parse HEAD)\\)"])

    child.stdout.on 'data', (data) ->
      res.end "#{data.toString().trim()} running node #{process.version} [pid: #{process.pid}]"
      child.stdin.end()

  robot.router.post "/hubot/broadcast", (req, res) ->
    room = req.body.room
    message = req.body.message
    if message
      user = robot.userForId 'broadcast'
      if room
        user.room = room
      robot.send user, message
      res.writeHead 200, {'Content-Type': 'text/plain'}
      res.end 'OK\n'
    else
      res.writeHead 400, {'Content-Type': 'text/plain'}
      res.end 'No Message\n'
