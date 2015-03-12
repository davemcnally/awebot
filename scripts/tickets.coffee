# A basic raffle system using points system. You can start a raffle
# at defined cost of points then close and draw a winner before reset.
# Having a separate reset allows for reopening the raffle to draw again
# without losing entrants.
#
# Command(s):
#   hubot raffle start <cost> - Start a raffle at <cost> points to enter
#   hubot raffle draw         - Close raffle, pick winner.
#   hubot raffle reset        - Clear entrants for the next raffle.
#   hubot ticket              - Enters raffle and takes <cost> points from entrant.

#
# Author:
#   Dave McNally

points = {}
username = {}
tickets = []
raffle = off
cost = 0
bought = []

save = (robot) ->
    robot.brain.data.points = points

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        points = robot.brain.data.points or {}

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
        entry = bought.indexOf(username)

        if points[username] >= cost and raffle is on
            if entry == -1
                points[username] -= cost
                bought.push(username)
                save(robot)
                msg.send "Test: raffle entered."
            else
                msg.send "Test: Seems you're already in the raffle."
            return

    # Close raffle, drawn winner and reset.
    robot.respond /raffle draw$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            winner = bought[Math.floor(Math.random() * bought.length)]
            raffle = off
            save(robot)
            msg.send "And the winner is..." + winner + "! Congrats!! Masonest will contact you via Twitch message with details on collecting your prize!"
            return

    # Reset raffle. Can start another a draw including current entrants before reset.
    robot.respond /raffle reset$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            bought.length = 0
            save(robot)
            return

    # Check entrants. Temp command for testing
    robot.respond /entrants$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            tickets = [username for username in bought]
            msg.send "Entrants for this raffle: " + tickets
            return
