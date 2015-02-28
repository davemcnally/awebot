# Just a test script for testing custom commands
#
# Command(s):
#   hubot testing — outputs test response

module.exports = (robot) ->
    robot.respond /testing/i, (msg) ->
        msg.send "I’m alive!"
