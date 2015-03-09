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
tickets = {}
raffle = {}
cost = {}
entered = {}

flatten = (array) ->
    Array::concat.apply([], array)

save = (robot) ->
    robot.brain.data.points = points
    robot.brain.data.tickets = tickets

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}
        tickets = robot.brain.data.tickets or {}

    robot.respond /raffle start (\d+)$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            cost = msg.match[1]
            raffle is on
            save(robot)

    robot.respond /raffle draw$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            raffle is off
            entered[username] is false
            save(robot)

    robot.respond /ticket$/i, (msg) ->
        username = "#{msg.envelope.user.name}"
        points[username] ?= 0

        if points[username] >= cost and raffle is on and entered[username] is false
            entered[username] is true
            points[username] -= cost
            save(robot)
            msg.send "Test: raffle entered."
        else
            msg.send "Test: cannot enter."
