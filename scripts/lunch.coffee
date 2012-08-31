# Description:
#   Suggestions where you should eat
#
# Commands:
#   hubot where should I eat <query>
#
# Examples:
#   hubot where should we eat
#   hubot where should we go for thai
#   hubot where should simon eat salad?

officeAddress = "EC2A 3LT"
radius = 600 # meters

yelp = require("yelp").createClient consumer_key: "8AWqlP20TDC1Bi2lMyeg2Q", consumer_secret: "Pj8d79VVotDEUbIZ5RI6nm2oTMI", token: "dcdR3RC_UUm1CB7NxePRPMpNB_d0xHaa", token_secret: "W0IK1K0xqPNTRKZ4jJQy4tSPgOw"

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
