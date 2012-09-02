# Description:
#   Interact with the desk.com API
#
# Dependencies:
#   "desk": "git://github.com/smulube/node-desk.git#fc30ba91b6",
#   "timeago": "0.1.0"
#
# Configuration:
#   HUBOT_DESK_SUBDOMAIN
#   HUBOT_DESK_CONSUMER_KEY
#   HUBOT_DESK_CONSUMER_SECRET
#   HUBOT_DESK_TOKEN
#   HUBOT_DESK_TOKEN_SECRET
#
# Commands:
#   hubot how many support
#   hubot how many pending support cases
#   hubot how many new,open support tickets
#   hubot show me support
#   hubot show me pending support cases
#   hubot show me new,open support tickets

subdomain = process.env.HUBOT_DESK_SUBDOMAIN
consumer_key = process.env.HUBOT_DESK_CONSUMER_KEY
consumer_secret = process.env.HUBOT_DESK_CONSUMER_SECRET
token = process.env.HUBOT_DESK_TOKEN
token_secret = process.env.HUBOT_DESK_TOKEN_SECRET

desk = require("desk").createClient subdomain: subdomain, \
              consumer_key:  consumer_key, \
              consumer_secret: consumer_secret, \
              token: token, \
              token_secret: token_secret

timeago = require("timeago")

module.exports = (robot) ->
  robot.respond /how many ([\w,]+)? ?support(\s+cases|\s+tickets)?/i, (msg) ->
    status = msg.match[1] or 'new,open'
    desk.cases status: status, (error, data) ->
      if error != null
        return msg.send "There was an error fetching data from the Desk.com api. Please check your config and try again"

      if data.total == 0
        msg.send "Wow, there are no cases in the '#{status}' state. Is everything alright with you guys?"
      else if data.total < 15
        msg.send "There are currently #{data.total} cases in the '#{status}' state. Not too shabby."
      else
        msg.send "Yikes, there are currently #{data.total} cases in the '#{status}' state. Time to put on your support hat!"
  robot.respond /show me ([\w,]+)? ?support(\s+cases|\s+tickets)?/i, (msg) ->
    status = msg.match[1] or 'new,open'
    desk.cases status: status, count: 10, (error, data) ->
      if error != null
        return msg.send "There was an error fetching data from the Desk.com API. Please check your config and try again."

      if data.total == 0
        msg.send "I have no cases to show you in the '#{status}' state."
      else
        count = if data.total > data.count then data.count else data.total
        msg.send "Here are the #{count} oldest cases in the '#{status}' state of a total #{data.total}:"
        for result in data.results
          ticket = "#{result.case.subject}"
          ticket += " - originally assigned to #{result.case.user.name}" if result.case.user
          ticket += ". Case last updated #{timeago(new Date(result.case.updated_at))}" if result.case.updated_at
          ticket += " (http://#{subdomain}.desk.com/agent/case/#{result.case.id})"
          msg.send ticket
