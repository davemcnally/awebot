# Just a test script for testing custom commands
#
# Command(s):
#   hubot wing — outputs test response

module.exports = (robot) ->
    robot.respond /wing$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            msg.send "NUT!"
            return
