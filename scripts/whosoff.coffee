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

calendarUrl = () ->
  calendar_id = process.env.HUBOT_WHOSOFF_CALENDAR_ID
  "https://staff.whosoff.com/feeds/?u=#{calendar_id}"

module.exports = (robot) ->
  ical = require("icalendar")
  robot.whosOff = (msg, cb) ->
    today = new Date
    tomorrow = new Date(today.getTime() + 86400)

    msg.http(calendarUrl())
      .get() (err, res, body) ->
        if res.statusCode == 200
          calendar = ical.parse_calendar(body)
          who = {}
          for event in calendar.events()
            if event.inTimeRange(today, tomorrow)
              data = [event.getPropertyValue("SUMMARY"),
                event.getPropertyValue("CATEGORIES")].join(" - ")
              date = new Date(event.getPropertyValue("DTEND"))
              who[data] = {until: date}

          cb who, null
        else
          cb null, err

  robot.respond /who'?s\s?off(\stoday)?/i, (msg) ->
    robot.whosOff msg, (who, error) ->
      if error != null
        msg.send "Unable to load calendar from url: #{calendarUrl()}"
      else
        lines = []
        for own name, props in who
          lines.push "    #{name} until #{props.until.toDateString()}"
          msg.send lines.join('\n')
