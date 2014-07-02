# Description:
#   Allows hubot to ban/unban and check bans for an Engine Yard environment
#
# Dependencies:
#   engineyard ruby gem.
#
# Configuration:
#   HUBOT_RANKIA_ENV
#   HUBOT_VEREMA_ENV
#
# Commands:
#   hubot ey check bans for|at|from rankia|verema <environment?> - Checks ban list for Rankia or Verema default or given environment
#   hubot ey ban <ip> for|at|from rankia|verema <environment?> - Adds a ban for given ip adress at Rankia or Verema default or given environment
#   hubot ey unban <ip> for|at|from rankia|verema <environment?> - Removes ban for given ip adress from Rankia or Verema default or given environment
#
# Author:
#   Emergia dev team.

child_process = require 'child_process'

rankiaEnv = process.env.HUBOT_RANKIA_ENV
veremaEnv = process.env.HUBOT_VEREMA_ENV

module.exports = (robot) ->

  robot.respond /ey (unban|ban) ((?:[0-9]{1,3}\.){3}[0-9]{1,3}) (?:for|at|from) (rankia|verema)(?:\s(\w*))?/i, (msg) ->
    action = msg.match[1]
    ip = msg.match[2]
    app = msg.match[3]
    env = msg.match[4]

    if not env?
      env = if app is 'rankia' then rankiaEnv else veremaEnv

    eval(action + 'EngineYard')(env, ip, msg)

  robot.respond /ey check bans (?:for|at|from) (rankia|verema)(?:\s(\w*))?/i, (msg) ->
    app = msg.match[1]
    env = msg.match[2]

    if not env?
      env = if app is 'rankia' then rankiaEnv else veremaEnv

    checkBansEngineYard(env, msg)

  banEngineYard = (env, ip, msg) ->
    banCommand = "sudo iptables -I INPUT -s #{ ip } -j DROP"
    msg.send "Banning #{ ip } at Engine Yard #{ env } servers..."
    callIptables(banCommand, env, msg)

  unbanEngineYard = (env, ip, msg) ->
    unbanCommand = "sudo iptables -D INPUT -s #{ ip } -j DROP"
    msg.send "Removing ban for #{ ip } at Engine Yard #{ env } servers..."
    callIptables(unbanCommand, env, msg)

  checkBansEngineYard = (env, msg) ->
    checkBansCommand = "sudo iptables -nvL"
    msg.send "Checking bans at Engine Yard #{ env } servers..."
    callIptables(checkBansCommand, env, msg)

  callIptables = (iptablesCommand, env, msg) ->
    command = "ey ssh \'#{ iptablesCommand }\' -e #{ env } --app-servers -t"

    child_process.exec command, (error, stdout, stderr) ->
      if error
        msg.send "Iptables command failed at #{ env } environment: "
        msg.send "\`\`\`#{ stderr }\`\`\`" # format output as code in Slack
      else
        msg.send "\`\`\`#{ stdout }\`\`\`"
        msg.send 'Done'
