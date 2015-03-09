# A basic raffle system using points system.
#
# Command(s):
#   hubot raffle start <cost> - Start a raffle at <cost> points to enter
#   hubot raffle draw         - Close raffle, pick winner and reset.
#   hubot ticket              - Enters raffle and takes <cost> points from entrant.

#
# Author:
#   Dave McNally

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
            msg.send "A raffle has now started and costs " + cost + " points to enter. If you have enough, use !ticket to enter. You can only enter once per raffle."

    robot.respond /raffle draw$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            raffle is off
            entered[username] is false
            save(robot)
            msg.send "The raffle is now closed. A winner will be announced in this message once finished."

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
