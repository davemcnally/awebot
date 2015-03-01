# A collection of common, simple text response
# commands that don’t require data from elsewhere
#
# Command(s):
#   hubot schedule    — Return the current stream schedule
#   hubot social      — Links to Twitter and Facebook
#   hubot commands    - Shows a current list of commands
#   hubot bot         - A quick bot about/introduction

module.exports = (robot) ->
    robot.respond /schedule$/i, (msg) ->
        msg.send "Our current schedule is Tuesday, Thursday, Saturday 10pm-1am GMT and Sunday 10pm-12am GMT."

    robot.respond /social$/i, (msg) ->
        msg.send "You can find me on Twitter at http://twitter.com/masonest_ and on Facebook at http://facebook.com/masonest"

    robot.respond /commands$/i, (msg) ->
        msg.send "I currently have a few commands you can use: !schedule, !social, !ctt/!tweet and !bot."

    robot.respond /bot$/i, (msg) ->
        msg.send "I’m Awebot. I am Masonest’s custom bot and was built by him. I’m still young and learning new things all the time."
