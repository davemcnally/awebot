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
bought = []

flatten = (array) ->
    Array::concat.apply([], array)

save = (robot) ->
    robot.brain.data.points = points

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}

    # Temp cycle of process to ready raffles.
    robot.respond /raffle reset$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            cost ?= 0
            raffle = on
            raffle = off
            entered[username] = false
            bought.length = 0
            save(robot)
            return

    # Start raffle with chosen cost.
    robot.respond /raffle start (\d+)$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            cost = msg.match[1]
            raffle = on
            save(robot)
            msg.send "A raffle has now started and costs " + cost + " points to enter. If you have enough, use !ticket to enter. You can only enter once per raffle."
            return

    # Enter an open raffle if you have enough points
    robot.respond /ticket$/i, (msg) ->
        username = "#{msg.envelope.user.name}"
        points[username] ?= 0

        if points[username] >= cost and raffle is on and entered[username] is false
            entered[username] = true
            points[username] -= cost
            bought.push(username)
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
            bought.length = 0
            save(robot)
            msg.send "The raffle is now closed. A winner will be announced in this message once finished."
            return

    # Check entrants. Temp command for testing
    robot.respond /entrants$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            tickets = [username for username in bought]
            msg.send "Entrants for this raffle: " + tickets
            return
