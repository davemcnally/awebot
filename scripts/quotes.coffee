# A basic quote system which allows viewers to add
# quotes and recall them both by ID and randomly.
#
# Command(s):
#   hubot quote add <message> - Add a quote containing <message>.
#   hubot quote <number>      - Recall a specific quote, <number> being the ID.
#   hubot quote               - Recall a random quote.
#
# Author:
#   Dave McNally

quotes = []

save = (robot) ->
    robot.brain.data.quotes = quotes

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        quotes = robot.brain.data.quotes or []

    # Create a new quote.
    robot.respond /quote add (.*?)\s?$/i, (msg) ->
        message = msg.match[1]
        quotes.push(message)
        save(robot)
        msg.send "Thanks, the quote has been added."

    robot.respond /quote$/i, (msg) ->
        pulled = quotes[Math.floor(Math.random() * quotes.length)]
        msg.send '"' + pulled + '"'
