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

Util = require "util"

flatten = (array) ->
    Array::concat.apply([], array)

award_hours = (msg, timename, hrs) ->
    hours[timename] ?= 0
    hours[timename] += parseInt(hrs)

save = (robot) ->
    robot.brain.data.hours = hours

module.exports = (robot) ->
    robot.brain.on 'loaded', ->
        hours = robot.brain.data.hours or {}

    # Compensate for resets and dropout. Name first. 100 = 1hr
    robot.respond /drop (.*?) (\d+)/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin'])
            award_hours(msg, msg.match[1], msg.match[2])
            save(robot)
            return

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

        msg.send "#{msg.envelope.user.name}, you have spent " + hourstotal + " hours in the channel!"

    robot.respond /top hours (\d*)$/i, (msg) ->
        if robot.auth.hasRole(msg.envelope.user, ['admin', 'moderator'])
            hourcount = msg.match[1]
            savedhours = robot.brain.get 'topwatchers'

            # Using "for in" is for iterating over an array.
            # Using "for of" is for iterating over properties of an object.
            watchedscores = [timename + " (" + hours[timename] / 100 + " hours)"] for timename of savedhours
            hourscore = watchedscores.slice(0, hourcount)

            # msg.send "The top #{hourcount} users with the most hours are: #{hourscore}"
            # Output of savedhours is "[object Object]"
            msg.send "Saved hours: " + hourscore

            # Inspect the object savedhours
            msg.send "Inspection: #{Util.inspect(savedhours)}"
