# A collection of common, simple text response
# commands that don’t require data from elsewhere
#
# Command(s):
#   hubot schedule    — Return the current stream schedule
#   hubot social      — Links to Twitter and Facebook
#   hubot commands    - Shows a current list of commands
#   hubot bot         - A quick bot about/introduction
#   hubot currency    - An explanation of points and the rate.
#   hubot blind       - A warning about spoilers and backseating.

module.exports = (robot) ->
    robot.respond /schedule$/i, (msg) ->
        msg.send "Our current schedule is Monday-Thursday from 9am until about 1pm GMT."

    robot.respond /social$/i, (msg) ->
        msg.send "You can find me on Twitter at http://twitter.com/masonest_ and on Facebook at http://facebook.com/masonest"

    robot.respond /(play|platforms)$/i, (msg) ->
        msg.send "Want to join me in game? Steam: Masonest / XBL: Masonest / PSN: MasonestTV / NNID: Masonest / 3DS Friend Code: 3797-9288-9986"

    robot.respond /commands$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            msg.send "Hey, #{msg.envelope.user.name}. Here's the commands that are available to you: !commands, !schedule, !social, !ctt/!tweet, !bot, !points, !hours, !uptime, !currency and !shoutout."
            return

        msg.send "Hey, #{msg.envelope.user.name}. Here's the commands that are available to you: !commands, !schedule, !social, !ctt/!tweet, !points, !hours, !uptime and !bot."

    robot.respond /bot$/i, (msg) ->
        msg.send "I’m Awebot. I am Masonest’s custom bot and was built by him. I’m still young and learning new things all the time."

    robot.respond /currency$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            msg.send "We use a points currency here. You get 5 points for every 15 minutes spent in the channel whilst we're live and 1 point per 15 minutes for time spent in here when offline. You can do !points to see your current balance. Points are used for our raffle system to buy entrance tickets!"
            return

    robot.respond /blind$/i, (msg) ->
        msg.send "This game is being played through for the first time. Mistakes will happen. Frequently. Please do not ruin it by posting spoilers/hints/tips of any kind."
