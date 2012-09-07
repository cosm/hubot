# Description:
#   Script for interacting with the Pingdom API.
#
# Dependencies:
#   none
#
# Configuration:
#   HUBOT_PINGDOM_USERNAME
#   HUBOT_PINGDOM_PASSWORD
#   HUBOT_PINGDOM_APP_KEY
#
# Commands:
#   hubot pingdom checks - returns summary of all checks pingdom currently monitoring
#   hubot pingdom alerts - returns list of most recent 10 alerts generated
#   hubot start watching pingdom - starts hubot periodically checking pingdom to see if any checks are down
#   hubot pingdom start - starts hubot periodically checking pingdom to see if any checks are down
#   hubot stop watching pingdom - stops hubot periodically checking pingdom
#   hubot pingdom stop - stops hubot periodically checking pingdom

username = process.env.HUBOT_PINGDOM_USERNAME
password = process.env.HUBOT_PINGDOM_PASSWORD
app_key = process.env.HUBOT_PINGDOM_APP_KEY
watch_interval = process.env.HUBOT_PINGDOM_WATCH_INTERVAL or 300000

class PingdomClient

  constructor: (@username, @password, @app_key, @watch_interval) ->

  start_watching: (msg) ->
    my = this
    msg.send "Started watching Pingdom. Will check every #{@watch_interval / 1000 / 60} minutes."
    @intervalId = setInterval () ->
      my.request msg, 'checks', (response) ->
        for check in response.checks
          if check.status.match /down/
            msg.send "Hey @everyone, Pingdom is reporting a status of #{check.status} for check: #{check.name}."
    , @watch_interval

  stop_watching: (msg) ->
    msg.send "Stopped watching Pingdom."
    clearInterval @intervalId

  checks: (msg) ->
    my = this
    my.request msg, 'checks', (response) ->
      if response.checks.length > 0
        lines = ["Here are the Pingdom checks:"]
        for check in response.checks
          lines.push "    #{check.name}. Status: #{check.status}. Last response time: #{check.lastresponsetime}ms"
        msg.send lines.join('\n')
      else
        msg.send "No checks found"

  actions: (msg) ->
    my = this
    my.request msg, 'actions?limit=10', (response) ->
      if response.actions.length > 0
        lines = ["Here are the most recent 10 Pingdodm alerts:"]
        for alert in response.actions
          lines.push "    At: #{new Date(alert.time).toISOString()}. Message: #{alert.messagefull}"
        msg.send lines.join('\n')
      else
        msg.send "No alerts found"

  request: (msg, url, handler) ->
    auth = new Buffer("#{@username}:#{@password}").toString('base64')
    pingdom_url = "https://api.pingdom.com/api/2.0"
    msg.http("#{pingdom_url}/#{url}")
      .headers(Authorization: "Basic #{auth}", 'App-Key': @app_key)
        .get() (err, res, body) ->
          if err
            msg.send "    Pingdom says: #{err}"
            return
          content = JSON.parse(body)
          if content.error
            msg.send "    Pingdom says: #{content.error.statuscode} #{content.error.errormessage}"
            return
          handler content

client = new PingdomClient(username, password, app_key, watch_interval)

module.exports = (robot) ->
  robot.respond /pingdom checks/i, (msg) ->
    client.checks msg

  robot.respond /pingdom alerts/i, (msg) ->
    client.actions msg

  robot.respond /(start watching pingdom)|(pingdom start)$/i, (msg) ->
    client.start_watching msg

  robot.respond /(stop watching pingdom)|(pingdom stop)$/i, (msg) ->
    client.stop_watching msg
