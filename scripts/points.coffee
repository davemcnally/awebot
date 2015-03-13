# A basic points system to build
# points over time. Can also be manually
# awarded.
#
# Command(s):
#   hubot give <number> points to <username>    - Award <number> points to <username>
#   hubot give <username> <number> points       - Award <number> points to <username>
#   hubot take <number> points from <username>  - Take away <number> points from <username>
#   hubot points                                - See how many points you have
#   hubot points <username>                     - See how many points <username> has
#   hubot take all points from <username>       - Removes all points from <username>
#
# Original Author:
#   brettlangdon

points = {}
username = {}
people = {}
pointrate = 0

Util = require "util"

flatten = (array) ->
    Array::concat.apply([], array)

# exports.flatten = flatten = (array) ->
#     flattened = []
#     for element in array
#         if element instanceof Array
#             flattened = flattened.concat flatten element
#         else
#             flattened.push element
#     flattened

award_points = (msg, username, pts) ->
    points[username] ?= 0
    points[username] += parseInt(pts)
    msg.send pts + ' Awarded To ' + username

save = (robot) ->
    robot.brain.data.points = points
    robot.brain.data.tickets = tickets

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}

    robot.respond /give (\d+) points to (.*?)\s?$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            award_points(msg, msg.match[2], msg.match[1])
            save(robot)
            return
        msg.send "Oi, #{msg.envelope.user.name}! You can't give yourself points!"

    robot.respond /give (.*?) (\d+) points/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            award_points(msg, msg.match[1], msg.match[2])
            save(robot)
            return
        msg.send "Oi, #{msg.envelope.user.name}! You can't give yourself points!"

    robot.respond /take all points from (.*?)\s?$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            username = msg.match[1].toLowerCase()
            points[username] = 0
            msg.send username + ' WHAT DID YOU DO?!'
            save(robot)
            return
        msg.send "Don't be so mean, #{msg.envelope.user.name}!"

    robot.respond /take (\d+) points from (.*?)\s?$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            pts = msg.match[1]
            username = msg.match[2].toLowerCase()
            points[username] ?= 0

            if points[username] is 0
                msg.send username + ' Does Not Have Any Points To Take Away'
            else
                points[username] -= parseInt(pts)
                msg.send pts + ' Points Taken Away From ' + username

            save(robot)
            return
        msg.send "Don't be so mean, #{msg.envelope.user.name}!"

    robot.respond /points ([a-zA-Z0-9_]*)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            username = msg.match[1].toLowerCase()
            points[username] ?= 0

            msg.send username + ' has ' + points[username] + ' points!'
            return

        msg.send "Only mods can check the points of others!"

    # Allows viewers to check their own point count
    robot.respond /points$/i, (msg) ->
        username = "#{msg.envelope.user.name}"
        points[username] ?= 0

        msg.send "#{msg.envelope.user.name}, you have " + points[username] + " points!"

    # Test online or offline
    robot.respond /status$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            robot.http("https://api.twitch.tv/kraken/streams/masonest")
                .get() (err, res, body) ->
                    streamer = JSON.parse(body)
                    if streamer.stream == null
                        msg.send "The stream is offline and point rate is " + pointrate + " point per hour."
                    else
                        msg.send "The stream is online and point rate is " + pointrate + " points per hour."

    # Points are only being given to myself regardless.
    setInterval (->
        robot.http("https://api.twitch.tv/kraken/streams/masonest")
        .get() (err, res, body) ->
            streamer = JSON.parse(body)
            if streamer.stream == null
                pointrate = 1
            else
                pointrate = 5

        robot.http("https://tmi.twitch.tv/group/user/masonest/chatters").get() (err, res, body) ->
            chat = JSON.parse(body)
            people = flatten([chat.chatters.moderators, chat.chatters.staff, chat.chatters.admins, chat.chatters.global_mods, chat.chatters.viewers]).filter((p) ->
                p != 'awebot'
            )

            for username in people
                points[username] ?= 0
                points[username] += pointrate
                save(robot)

            # Winners (and then recall) is equal to all users
            # with points, and their points respectively.
            robot.brain.set 'winners', points
    ), 60000
    # 3600000 for an hour

    # Get a list of stored people and points
    robot.respond /getset$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            recall = robot.brain.get 'winners'

            # Outputs [object Object]
            # msg.send "#{recall}"

            # Outputs an inspection of recall which comes out as:
            # { masonest: 3670, awebot: 3860, knexem: 3455 }
            msg.send "Inspection: #{Util.inspect(recall)}"

    robot.respond /top (\d*)$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            pointcount = msg.match[1]
            recall = robot.brain.get 'winners'

            scores = [username + " has " + points[username]] for username of recall

            topscore = scores.sort((a, b) ->
                b.points[username] - a.points[username]
            ).slice(0, pointcount)

            # msg.send "The top #{pointcount} users with the most points are: #{topscore}"
            msg.send "Scores: #{topscore}"
