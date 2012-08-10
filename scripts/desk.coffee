# Description
#   A way to interact with the desk.com API.
#
# Commands:
#   hubot desk tickets - Returns a count of how many tickets are currently waiting to be dealt with

module.exports = (robot) ->
  robot.respond /desk tickets/i, (msg) ->
      msg.send "dunno"
