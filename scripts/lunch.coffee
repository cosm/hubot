# Description:
#   Suggestions where you should eat
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_LUNCH_YELP_CONSUMER_KEY
#   HUBOT_LUNCH_YELP_CONSUMER_SECRET
#   HUBOT_LUNCH_YELP_TOKEN
#   HUBOT_LUNCH_YELP_TOKEN_SECRET
#   HUBOT_LUNCH_ADDRESS
#   HUBOT_LUNCH_RADIUS
#
# Commands:
#   hubot where should I eat <query>
#
# Examples:
#   hubot where should we eat
#   hubot where should we go for thai
#   hubot where should simon eat salad?

officeAddress = process.env.HUBOT_LUNCH_ADDRESS
radius = process.env.HUBOT_LUNCH_RADIUS or 600

consumer_key = process.env.HUBOT_LUNCH_YELP_CONSUMER_KEY
consumer_secret = process.env.HUBOT_LUNCH_YELP_CONSUMER_SECRET
token = process.env.HUBOT_LUNCH_YELP_TOKEN
token_secret = process.env.HUBOT_LUNCH_YELP_TOKEN_SECRET

yelp = require("yelp").createClient consumer_key: consumer_key, consumer_secret: consumer_secret, token: token, token_secret: token_secret

_ = require("underscore")

eatAt = (msg, query) ->

module.exports = (robot) ->
  findUsers = (msg, username) ->
    if username.match(/^i$/i)
      username = msg.message.user.name

    if username.match(/^we$/i)
      robot.brain.data.users # Hook this into Whosoff!
    else
      robot.usersForFuzzyName(username)

  dietaryRestrictions = (msg, username) ->
    users = findUsers(msg, username)
    restrictions = []
    for own key, user of users
      for own i, role of user.roles
        if String(role).match(/vegetarian/i)
          restrictions.push("vegetarian")
        if String(role).match(/vegan/i)
          restrictions.push("vegan")

    _.uniq(restrictions, false, _.identity).join(' ')

  robot.respond /where should (\w+) (eat|go for)(.*)/i, (msg) ->
    query = msg.match[3]
    query = query.replace(/^\s+|\s+$|[!\?]+$/g, '')
    query = "food" if (typeof query == "undefined" || query == "")
    query = dietaryRestrictions(msg, msg.match[1]) + " " + query
    # msg.send("Query: "+query)
    yelp.search term: query, radius_filter: radius, sort: 2, limit: 20, location: officeAddress, (error, data) ->
      if error != null
        return msg.send "There was an error finding food. So hungry..."

      if data.total == 0
        return msg.send "I couldn't find any food for you. Good Luck!"

      business = data.businesses[Math.floor(Math.random() * data.businesses.length)]
      msg.send "How about "+business.name+"? "+business.url
