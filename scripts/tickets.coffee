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
tickets = {}
raffle = {}
cost = {}
entered = {}
entrants = {}

flatten = (array) ->
    Array::concat.apply([], array)

save = (robot) ->
    robot.brain.data.points = points
    robot.brain.data.entrants = entrants

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}
        tickets = robot.brain.data.tickets or {}

    # Start raffle with chosen cost.
    robot.respond /raffle start (\d+)$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            cost = msg.match[1]
            raffle = on
            save(robot)
            msg.send "A raffle has now started and costs " + cost + " points to enter. If you have enough, use !ticket to enter. You can only enter once per raffle."
            return

        msg.send "Only Masonest can start raffles!"

    # Enter an open raffle if you have enough points
    robot.respond /ticket$/i, (msg) ->
        username = "#{msg.envelope.user.name}"
        points[username] ?= 0
        entrants = flatten([entered[username]])

        if points[username] >= cost and raffle is on and entered[username] is false
            entered[username] = true
            points[username] -= cost
            save(robot)
            msg.send "Test: raffle entered."
        else
            if points[username] <= cost
                msg.send "Test: Not enough points."
            if raffle isnt on
                msg.send "Test: raffle isn't running."
            if entered[username] is true
                msg.send "Test: You already entered."

    # Close raffle, drawn winner and reset.
    robot.respond /raffle draw$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            raffle = off
            entered[username] = false
            save(robot)
            msg.send "The raffle is now closed. A winner will be announced in this message once finished."
            return

        msg.send "Only Masonest can close a raffle."

    # Check entrants. Temp command for testing
    robot.respond /entrants$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            tickets = [entered[username] for username in entrants]
            msg.send "Entrants for this raffle: " + tickets
            return
