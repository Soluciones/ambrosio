# Description:
#   Allows hubot to check an Engine Yard app environment status and to answer the EY response.
#
# Dependencies:
#   engineyard ruby gem.
#
# Configuration:
#   HUBOT_RANKIA_APP
#   HUBOT_RANKIA_ENV
#   HUBOT_VEREMA_APP
#   HUBOT_VEREMA_ENV
#
# Commands:
#   hubot check ey status for rankia - Checks ey status info for Rankia default environment
#   hubot check ey status for verema - Checks ey status info for Verema default environment
#   hubot check ey status for rankia environment - Checks ey status info for Rankia given environment
#   hubot check ey status for verema environment - Checks ey status info for Verema given environment
#
# Author:
#   Emergia dev team.

child_process = require 'child_process'

eyApiToken = process.env.EY_API_TOKEN
rankiaApp = process.env.HUBOT_RANKIA_APP
rankiaEnv = process.env.HUBOT_RANKIA_ENV
veremaApp = process.env.HUBOT_VEREMA_APP
veremaEnv = process.env.HUBOT_VEREMA_ENV

module.exports = (robot) ->

  robot.respond /check ey status for rankia(?:\s(\w*))?/i, (msg) ->
    rankiaEnv = msg.match[1] or rankiaEnv
    checkEngineYard(rankiaApp, rankiaEnv, msg)

  robot.respond /check ey status for verema(?:\s(\w*))?/i, (msg) ->
    veremaEnv = msg.match[1] or veremaEnv
    checkEngineYard(veremaApp, veremaEnv, msg)

  checkEngineYard = (app, env, msg) ->
    msg.send "Checking the status for #{ app }\/#{ env } at Engine Yard..."
    child_process.exec "ey status --app=#{ app } -e #{ env } --api-token=#{ eyApiToken }", (error, stdout, stderr) ->
      if error
        msg.send "Status checking failed for #{ app } application and #{ env } environment: " + stderr
      else
        msg.send stdout+''
