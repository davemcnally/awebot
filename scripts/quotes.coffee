# Description:
#   A script for creating and recalling quotes from the chat using regular expressions and ID numbers
#
# Commands:
#   hubot quote add <quote>                - Adds the specified quote. Regulars and up only.
#   hubot quote delete|remove <quote ID>   - Remove the specified quote. Mod and up only.
#   hubot quote <ID>                       - Return a specific quote.
#   hubot quote delete|remove all          - Removes all quotes. Admin only.
#
# Author:
#   Adapted from johnwyles' hubot-quote-database
#   https://github.com/johnwyles/hubot-quote-database/blob/master/src/quote_database.coffee

module.exports = (robot) ->
    # The maximum number of quotes output for a search.
    maximum_quotes_output = 1

    default_quote_database = {
        "next_id": 1,
        "quotes": [
            {"id": 0, "quote": "First quote"}
        ],
        "rmquote": []
    }

    robot.brain.on 'loaded', ->
        robot.brain.data.quote_database = default_quote_database if robot.brain.data.quote_database is undefined

    # Add a quote.
    robot.respond /quote add\s?(.*)?$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator', 'regular'])
            if msg.match[1]
                for quote_index in robot.brain.data.quote_database.quotes
                    if quote_index.quote == msg.match[1]
                        msg.send "This quote already exists [ID: #{quote_index.id}]."
                        return
                quote_id = robot.brain.data.quote_database.next_id++
                robot.http("https://api.twitch.tv/kraken/channels/dayvemsee")
                    .get() (err, res, body) ->
                        streamer = JSON.parse(body)

                        now = new Date
                        date = "#{now.getMonth() + 1}/#{now.getDate()}/#{now.getFullYear()}"
                        game = if streamer.game then "[#{streamer.game} on #{date}]" else "[#{date}]"

                        quote = "#{msg.match[1]} #{game}"
                        robot.brain.data.quote_database.quotes.push {"id": quote_id, "quote": quote}
                        msg.send "Your quote has been added [ID: #{quote_id}]."
            else
                msg.send "The quote cannot be blank."

    # Delete a quote.
    robot.respond /quote (delete|remove)\s?(\d+)?$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            if msg.match[2]
                if robot.brain.data.quote_database.rmquote[msg.match[2]]
                    for quote_index in robot.brain.data.quote_database.quotes
                        if quote_index.id is parseInt(msg.match[2])
                            robot.brain.data.quote_database.quotes.splice robot.brain.data.quote_database.quotes.indexOf(quote_index), 1
                            msg.send "This quote has been removed [ID: #{quote_index.id}]."
                            robot.brain.data.quote_database.rmquote[msg.match[2]] = false
                            return
                    msg.send "This quote ID is invalid [ID: #{msg.match[2]}]."
            else
                msg.send "You need to specify a quote ID to remove."

    # Returns stored quotes.
    robot.respond /quote\s?(?: (\d+))?$/i, (msg) ->
        quote_database = robot.brain.data.quote_database

        # Returns a random quote.
        if not msg.match[1]
            random_quote_index = Math.floor(Math.random() * quote_database.quotes.length)
            random_quote = quote_database.quotes[random_quote_index]
            msg.send "#{random_quote.quote} [ID: #{random_quote.id}]"
            return

        # Returns a specific quote by ID.
        else if msg.match[1]
            for quote_index in robot.brain.data.quote_database.quotes
                if quote_index.id is parseInt(msg.match[1])
                    msg.send "#{quote_index.quote} [ID: #{quote_index.id}]"
                    return
            msg.send "The quote ID seems invalid [ID: #{msg.match[1]}]."

    robot.respond /quote (delete|remove) all$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            robot.brain.data.quote_database = default_quote_database
            msg.send "All quotes have been removed."
