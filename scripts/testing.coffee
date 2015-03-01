# Just a test script for testing custom commands
#
# Command(s):
#   hubot ding — outputs test response

module.exports = (robot) ->
    robot.respond /ding$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            msg.send "DONG!"
        else
            msg.send "Sorry #{msg.envelope.user.name}, only Masonest can do that."
