# Description:
#     Commands that pull in dynamic info
#     from the Twitch API and possibly others
#
# Commands:
#     hubot shoutout: Return the current stream schedule
#     hubot ctt || tweet: Dynamic tweet link generated.

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
        msg.send "Hey #{msg.envelope.user.name}, only mods and dayvemsee can do that!"

    robot.respond /(ctt|tweet)$/i, (msg) ->
        message = "If you’re enjoying the stream, please share it with your friends!"

        robot.http("https://api.twitch.tv/kraken/channels/dayvemsee")
            .get() (err, res, body) ->
                streamer = JSON.parse(body)
                game = if streamer.game then "play some #{streamer.game} " else ""
                tweet = "Come watch @dayvemsee #{game}at http://twitch.tv/dayvemsee and hang out in the chat!"
                tweet = encodeURIComponent(tweet)
                url = "https://twitter.com/intent/tweet?text=#{tweet}&source=clicktotweet"

                # See if we’ve already shortened this before.
                msg.http("https://api-ssl.bitly.com/v3/link/lookup")
                    .query
                        access_token: process.env.HUBOT_BITLY_ACCESS_TOKEN
                        longUrl: url
                        format: "json"
                    .get() (err, res, body) ->
                        response = JSON.parse body
                        if response.data.link_lookup.aggregate_link
                            msg.send "#{message} #{response.data.link_lookup.aggregate_link}."
                            return

                # After gathering dynamic link content, send to bitly.
                msg.http("https://api-ssl.bitly.com/v3/shorten")
                    .query
                        access_token: process.env.HUBOT_BITLY_ACCESS_TOKEN
                        longUrl: url
                        format: "json"
                    .get() (err, res, body) ->
                        response = JSON.parse body
                        response = if response.status_code is 200 then response.data.url else response.status_txt
                        msg.send "#{message} #{response}."
