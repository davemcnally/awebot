# Commands that pull in dynamic info
# from the Twitch API and possibly others
#
# Command(s):
#   hubot shoutout    — Return the current stream schedule

module.exports = (robot) ->
    robot.respond /shoutout ([a-zA-Z0-9_]*)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            query = msg.match[1]
            robot.http("https://api.twitch.tv/kraken/channels/#{query}")
                .get() (err, res, body) ->
                    streamer = JSON.parse(body)

                    if streamer.status == 404
                        msg.send "That user doesn’t appear to exist, please check your spelling!"
                        return

                    shout = "Check out the awesome #{streamer.display_name} at #{streamer.url}!"
                    if streamer.game
                        shout = "#{shout} They’ve recently been playing #{streamer.game}."
                    msg.send shout

            return

        #If user doesn’t have permission to shoutout
        msg.send "Hey #{msg.envelope.user.name}, only mods and Masonest can do that!"
