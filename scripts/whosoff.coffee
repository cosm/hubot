# Description:
#   Grab ical data from whosoff and show who is off
#
# Dependencies:
#   "icalendar": "0.6.3"
#
# Configuration:
#   HUBOT_WHOSOFF_CALENDAR_ID
#
# Commands:
#   hubot whosoff - Show who's off today
#
# Author:
#   smulube

module.exports = (robot) ->
  ical = require("icalendar")
  robot.respond /who'?s\s?off(\stoday)?/i, (msg) ->
    calendar_id = process.env.HUBOT_WHOSOFF_CALENDAR_ID
    calendar_url = "https://staff.whosoff.com/feeds/?u=#{calendar_id}"
    today = new Date
    tomorrow = new Date(today.getTime() + 86400)

    msg.http(calendar_url)
      .get() (err, res, body) ->
        if res.statusCode == 200
          calendar = ical.parse_calendar(body)
          lines = []
          for event in calendar.events()
            if event.inTimeRange(today, tomorrow)
              data = [event.getPropertyValue("SUMMARY"),
                event.getPropertyValue("CATEGORIES")].join(" - ")
              date = new Date(event.getPropertyValue("DTEND"))
              lines.push "    #{data} until #{date.toDateString()}"
          msg.send lines.join('\n')
        else
          msg.send "Unable to load calendar from url: #{calendar_url}"
