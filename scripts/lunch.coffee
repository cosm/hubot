# Description:
#   Suggestions where you should eat
#
# Commands:
#   hubot where should I eat
#   hubot where should we eat
#   hubot where should we eat thai
#   hubot where should we eat lunch

officeAddress = "EC2A 3LT"
radius = 600 # meters

yelp = require("yelp").createClient consumer_key: "8AWqlP20TDC1Bi2lMyeg2Q", consumer_secret: "Pj8d79VVotDEUbIZ5RI6nm2oTMI", token: "dcdR3RC_UUm1CB7NxePRPMpNB_d0xHaa", token_secret: "W0IK1K0xqPNTRKZ4jJQy4tSPgOw"

eatAt = (msg, query) ->
  query = query.replace(/^\s+|\s+$|[!\?]+$/g, '')
  query = "food" if (typeof query == "undefined" || query == "")
  yelp.search term: query, radius_filter: radius, sort: 2, limit: 20, location: officeAddress, (error, data) ->
    if error != null
      return msg.send "There was an error finding food. So hungry..."

    if data.total == 0
      return msg.send "I couldn't find any food for you. Good Luck!"

    business = data.businesses[Math.floor(Math.random() * data.businesses.length)]
    msg.send "How about "+business.name+"? "+business.url

module.exports = (robot) ->
  robot.respond /where should \w+ eat(.*)/i, (msg) ->
    eatAt msg, msg.match[1]
