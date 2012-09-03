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
#   hubot whosoff tomorrow - Show who's off tomorrow
#   hubot whosoff next week - Show who's off next week
#
# Author:
#   smulube

module.exports = (robot) ->
  ical = require("icalendar")
  robot.respond /who'?s\s?off\s?([\w\s]+)?$/i, (msg) ->
    calendar_id = process.env.HUBOT_WHOSOFF_CALENDAR_ID
    calendar_url = "https://staff.whosoff.com/feeds/?u=#{calendar_id}"
    query = msg.match[1]

    today = new Date

    switch query
      when "next week"
        start_date = new Date(today.getTime() + (86400 * 1000 * (8 - today.getDay())))
        end_date = new Date(start_date.getTime() + (86400 * 1000 * 5))
      when "tomorrow"
        start_date = new Date(today.getTime() + (86400 * 1000))
        end_date = start_date
      else
        query = "today"
        start_date = today
        end_date = today

    msg.http(calendar_url)
      .get() (err, res, body) ->
        if res.statusCode == 200
          calendar = ical.parse_calendar(body)
          lines = []
          counter = 0
          for event in calendar.events()
            if event.inTimeRange(start_date, end_date)
              counter += 1
              data = [event.getPropertyValue("SUMMARY"),
                event.getPropertyValue("CATEGORIES")].join(" - ")
              from = new Date(event.getPropertyValue("DTSTART"))
              to = new Date(event.getPropertyValue("DTEND"))
              if from.toDateString() == to.toDateString()
                lines.push "    #{data} from #{from.toLocaleTimeString()} to #{to.toLocaleTimeString()} on #{from.toDateString()}"
              else
                lines.push "    #{data} from #{from.toDateString()} to #{to.toDateString()}"
          if counter > 0
            msg.send lines.join('\n')
          else
            msg.send "According to whosoff no one should be off #{query}."
        else
          msg.send "Unable to load calendar from url: #{calendar_url}"
