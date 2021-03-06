# Description:
#     A basic points system to build
#     points over time. Can also be manually
#     awarded.
#
# Commands:
#     hubot give <number> points to <username>: Award <number> points to <username>
#     hubot give <username> <number> points: Award <number> points to <username>
#     hubot take <number> points from <username>: Take away <number> points from <username>
#     hubot points: See how many points you have
#     hubot points <username>: See how many points <username> has
#     hubot take all points from <username>: Removes all points from <username>
#     hubot top points <number>: Show the top <number> point counts.
#
# Author:
#     brettlangdon
#     davemcnally

points = {}
username = {}
people = {}
pointrate = 0

Util = require "util"

flatten = (array) ->
    Array::concat.apply([], array)

award_points = (msg, username, pts) ->
    points[username] ?= 0
    points[username] += parseInt(pts)
    msg.send pts + ' Awarded To ' + username

save = (robot) ->
    robot.brain.data.points = points

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

    # Points are only being given to myself regardless.
    setInterval (->
        robot.http("https://api.twitch.tv/kraken/streams/dayvemsee").get() (err, res, body) ->
            streamer = JSON.parse(body)
            if streamer.stream == null
                pointrate = 1
            else
                pointrate = 5

        robot.http("https://tmi.twitch.tv/group/user/dayvemsee/chatters").get() (err, res, body) ->
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
    ), 900000
    # 900000 for 15 mins

    # Get a list of stored people and points
    robot.respond /getset$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            recall = robot.brain.get 'winners'

            # Outputs [object Object]
            # msg.send "#{recall}"

            # Outputs an inspection of recall which comes out as:
            # { dayvemsee: 3670, awebot: 3860, knexem: 3455 }
            msg.send "Inspection: #{Util.inspect(recall)}"

    robot.respond /top points (\d*)$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            pointcount = msg.match[1]
            recall = robot.brain.get 'winners'

            pointScore = (list) ->
              (a, b) ->
                list[b] - list[a]

            displaypointScore = (list) ->
              (user, index) ->
                index + 1 + '. ' + user + ' (' + list[user] + ')'

            toppoints = Object.keys(recall).sort(pointScore(recall))
            toppeoplepoints = toppoints.map(displaypointScore(recall)).slice(0, pointcount).join(', ')

            msg.send "The top " + pointcount + " people for total points: " + toppeoplepoints
