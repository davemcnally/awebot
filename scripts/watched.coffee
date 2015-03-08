# Description:
#   A simple script to store and show hours that people
#   have been in the channel for.
#
# Commands:
#   hubot hours            - See how many hours you have.
#   hubot hours <username> - See how many hours <username> has.
#
# Author:
#   Derived from points.coffee by brettlangdon

hours = {}
timename = {}
timepeople = {}
hourstotal = {}

# Util = require "util"

flatten = (array) ->
    Array::concat.apply([], array)

award_hours = (msg, timename, hrs) ->
    hours[timename] ?= 0
    hours[timename] += parseInt(hrs)
    msg.send hrs + ' Awarded To ' + timename

save = (robot) ->
    robot.brain.data.hours = hours

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        hours = robot.brain.data.hours or {}

    # Give users 5 points each 3 mins which is 100/hr
    setInterval (->
        robot.http("https://tmi.twitch.tv/group/user/masonest/chatters").get() (err, res, body) ->
            chat = JSON.parse(body)
            timepeople = flatten([chat.chatters.moderators, chat.chatters.staff, chat.chatters.admins, chat.chatters.global_mods, chat.chatters.viewers]).filter((watchers) ->
                watchers != 'awebot'
            )

            for timename in timepeople
                hours[timename] ?= 0
                hours[timename] += 5
                save(robot)

            # Store in brain for leaderboards later.
            robot.brain.set 'topwatchers', hours
    ), 180000

    # Admin and mods can check the hours of others
    robot.respond /hours ([a-zA-Z0-9_]*)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            timename = msg.match[1].toLowerCase()
            hours[timename] ?= 0
            hourstotal = hours[timename] / 100

            msg.send timename + ' has spent ' + hourstotal + ' hours in the channel!'
            return

        msg.send "Only mods can check the hours of others!"

    # Allows viewers to check their own hours watched.
    robot.respond /hours$/i, (msg) ->
        timename = "#{msg.envelope.user.name}"
        hours[timename] ?= 0
        hourstotal = hours[timename] / 100

        msg.send "#{msg.envelope.user.name}, you have spent " + hourstotal + " in the channel!"

    #
    # We don’t need the following until it's fully
    # functional for our points system first. Just
    # having a stat and totals is enough for now.
    #

    # # Get a list of stored timepeople and hours
    # robot.respond /gethours$/i, (msg) ->
    #     if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
    #         savedhours = robot.brain.get 'topwatchers'
    #
    #         # Outputs [object Object]
    #         # msg.send "#{savedhours}"
    #
    #         # Outputs an inspection of savedhours which comes out as:
    #         # { masonest: 3670, awebot: 3860, knexem: 3455 }
    #         msg.send "Inspection: #{Util.inspect(savedhours)}"

    # robot.respond /top hours (\d*)$/i, (msg) ->
    #     if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
    #         hourcount = msg.match[1]
    #         savedhours = robot.brain.get 'topwatchers'
    #
    #         watchedscores = [timename + " has " + hours[timename]] for timename of savedhours
    #
    #         hourscore = watchedscores.sort((a, b) ->
    #             b.hours[timename] - a.hours[timename]
    #         ).slice(0, hourcount)
    #
    #         # msg.send "The top #{hourcount} users with the most hours are: #{hourscore}"
    #         msg.send "Top watched scores: #{hourscore}"
