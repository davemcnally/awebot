# Moderation for Awebot which should
# help remove need for other bots. Most
# will be hearing responses, not called.
#
# Command(s):

module.exports = (robot) ->
    robot.hear /(\S+\.(com|net|org|edu|gov|ly|io|co.uk|co)(\/\S+)?)/i, (msg) ->
        unless robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator', 'regular'])
            msg.send "/timeout #{msg.envelope.user.name} 1"
            msg.send "Watch it, #{msg.envelope.user.name}! You need permission to post links."
            return
