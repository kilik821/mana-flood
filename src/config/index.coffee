#### Config file
# Sets application config parameters depending on `env` name
exports.setEnvironment = (env) ->
  console.log "set app environment: #{env}"
  switch(env)
    when "development"
      exports.DEBUG_LOG = true
      exports.DEBUG_WARN = true
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = true
      exports.DB_HOST = 'localhost'
      exports.DB_PORT = "27017"
      exports.DB_NAME = 'manaflood-dev'
      exports.DB_USER = ''
      exports.DB_PASS = ''

    when "testing"
      exports.DEBUG_LOG = true
      exports.DEBUG_WARN = true
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = true

    when "production"
      exports.DEBUG_LOG = false
      exports.DEBUG_WARN = false
      exports.DEBUG_ERROR = true
      exports.DEBUG_CLIENT = false
      exports.DB_HOST = 'alex.mongohq.com'
      exports.DB_PORT = "10057"
      exports.DB_NAME = 'nodejitsudb7142908009'
      exports.DB_USER = 'nodejitsu'
      exports.DB_PASS = '987e79cd69426657761c86780f84bdf6'
    else
      console.log "environment #{env} not found"

exports.secret = '98q1eq98e18984qe'