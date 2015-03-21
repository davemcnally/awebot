# Moderation for Awebot which should
# help remove need for other bots. Most
# will be hearing responses, not called.
#
# Command(s):
#   hubot uptime - Return the current uptime, if live.

module.exports = (robot) ->
    robot.hear /(\S+\.(com|net|org|edu|gov|ly|io|co.uk|co)(\/\S+)?)/i, (msg) ->
        unless robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator', 'regular'])
            msg.send "/timeout #{msg.envelope.user.name} 1"
            msg.send "Watch it, #{msg.envelope.user.name}! You need permission to post links."
            return

    robot.hear /(nigger\w*|nigga\w*|cunt\w*|fag\w*|queer\w*|twat\w*)/i, (msg) ->
        unless robot.auth.hasRole(msg.envelope.user, ['admin'])
            msg.send "/timeout #{msg.envelope.user.name} 1"
            msg.send "#{msg.envelope.user.name}! That kind of language is not acceptable."
            return

    robot.hear /uptime$/i, (msg) ->
        robot.http("https://api.twitch.tv/kraken/streams/masonest").get() (err, res, body) ->
            streamer = JSON.parse(body)
            if streamer.stream == null
                msg.send "Masonest is not currently live."
            else
                robot.http("https://nightdev.com/hosted/uptime.php?channel=masonest").get() (err, res, body) ->
                    msg.send "We’ve been live for #{body}."
