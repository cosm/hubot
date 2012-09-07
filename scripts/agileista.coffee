# Description:
#   Link to Agileista stories when we see a #123 pattern.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_AGILEISTA_DOMAIN
#   HUBOT_AGILEISTA_API_KEY
#
# Commands:
#   hubot show me #1234 - Show agileista ticket number 1234 (if it exists)
#
# Author:
#   smulube

module.exports = (robot) ->
  robot.respond /show\sme\s#(\d+)/i, (msg) ->
    domain = process.env.HUBOT_AGILEISTA_DOMAIN
    api_key = process.env.HUBOT_AGILEISTA_API_KEY

    story_id = escape(msg.match[1])

    msg.http("https://#{domain}.agileista.com/user_stories/#{story_id}.json?key=#{api_key}")
      .get() (err, res, body) ->
        if res.statusCode == 200
          object = JSON.parse(body)
          lines = []
          lines.push "    #{object.definition}"
          if object.story_points
            lines.push "    #{object.story_points} story points"
          lines.push "    https://#{domain}.agileista.com/user_stories/#{story_id}"
          msg.send lines.join('\n')
        else
          msg.send "Story ##{story_id} not found."
