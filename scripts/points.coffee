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
            username = msg.match[1]
            points[username] = 0
            msg.send username + ' WHAT DID YOU DO?!'
            save(robot)
            return
        msg.send "Don't be so mean, #{msg.envelope.user.name}!"

    robot.respond /take (\d+) points from (.*?)\s?$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            pts = msg.match[1]
            username = msg.match[2]
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
            username = msg.match[1]
            points[username] ?= 0

            msg.send username + ' has ' + points[username] + ' points!'
            return

        msg.send "Only mods can check the points of others!"

    robot.respond /points$/i, (msg) ->
        username = "#{msg.envelope.user.name}"
        points[username] ?= 0

        msg.send "#{msg.envelope.user.name}, you have " + points[username] + " points!"

    setInterval (->
        robot.http("https://tmi.twitch.tv/group/user/masonest/chatters").get() (err, res, body) ->
            chat = JSON.parse(body)
            people = flatten([chat.chatters.moderators, chat.chatters.staff, chat.chatters.admins, chat.chatters.global_mods, chat.chatters.viewers])

            robot.brain.set 'winners', people

            for username in people
                points[username] ?= 0
                points[username] += 5
                save(robot)
    ), 60000

    # Get a list of stored people and points
    robot.respond /getset$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])

            pointcount = robot.brain.get 'winners'
            savescore = ["#{username} has #{attrs.points}" for username, attrs of pointcount]
            msg.send "Top points: #{savescore}"

    # robot.respond /top (\d*)$/i, (msg) ->
    #     if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
    #         pointcount = msg.match[1]
    #
    #         savednames = [robot.brain.get "people.username"]
    #         savedpoints = [robot.brain.get "people.username.points"]
    #
    #         score = ["#{savednames} has #{savedpoints[savednames]}"]
    #
    #         topscore = score.sort((a, b) ->
    #             b.savedpoints[savednames] - a.savedpoints[savednames]
    #         ).slice(0, pointcount)
    #
    #         msg.send "The top #{pointcount} users with the most points are: #{topscore}"

    # Manual data retrieval from object values
    # robot.respond /getset1$/i, (msg) ->
    #     if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
    #
    #         saved =
    #             masonest:
    #                 coins: 20
    #             knexem:
    #                 coins: 12
    #             phillyf:
    #                 coins: 1
    #             superking:
    #                 coins: 30
    #
    #         robot.brain.set 'winners', saved
    #         coincount = robot.brain.get 'winners'
    #         savescore = ["#{user} has #{attrs.coins}" for user, attrs of coincount]
    #         msg.send "Coins: #{savescore}"
