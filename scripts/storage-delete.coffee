# Description:
#   Delete the data in redis easily
#
# Commands:
#   hubot storage delete <key>  - Remove a top level storage key from the brain.

module.exports = (robot) ->
  robot.respond /storage delete (\w*)$/i, (msg) ->
    if msg.match[1] isnt 'users'
      delete robot.brain.data[msg.match[1]]
      msg.send "#{msg.match[1]} deleted from storage"
