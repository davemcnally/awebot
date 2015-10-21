# Moderation for Awebot which should
# help remove need for other bots. Most
# will be hearing responses, not called.
#
# Command(s):
#   hubot uptime - Return the current uptime, if live.

module.exports = (robot) ->
    robot.hear /(\S+\.(com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|xyz|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)(\/\S+)?)/i, (msg) ->
        unless robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator', 'regular'])
            msg.send "/timeout #{msg.envelope.user.name} 1"
            msg.send "Hey #{msg.envelope.user.name}, only regulars can post links."
            return

    robot.hear /uptime$/i, (msg) ->
        robot.http("https://api.twitch.tv/kraken/streams/masonest").get() (err, res, body) ->
            streamer = JSON.parse(body)
            if streamer.stream == null
                msg.send "Masonest is not currently live."
            else
                robot.http("https://nightdev.com/hosted/uptime.php?channel=masonest").get() (err, res, body) ->
                    msg.send "We’ve been live for #{body}."

    robot.hear /permit ([a-zA-Z0-9_]*)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            name = msg.match[1]
            user = robot.brain.userForName(name)
            tempRole = "regular"

            user.roles.push(tempRole)
            msg.send "Okay, #{name} has permission for the next 2 minutes to post a link."

            setTimeout () ->
                user.roles = (role for role in user.roles when role isnt tempRole)
            , 60 * 2000
        else
            msg.send "Hey #{msg.envelope.user.name}, only mods and Masonest can do that!"
