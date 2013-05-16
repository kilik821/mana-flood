express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
mongoose = require 'mongoose'
mongoStore = require('connect-mongo')(express)
updates = require './update'

#### Basic application initialization
# Create app instance.
app = express()

# Define Port
app.port = process.env.PORT or process.env.VMC_APP_PORT or 3000

# Schedule updates
updates.scheduleMaintenance 24*60*60, (err)->
  console.log err

# Config module exports has `setEnvironment` function that sets app settings depending on environment.
config = require "./config"
app.configure 'production', 'development', 'testing', ->
  config.setEnvironment app.settings.env

#db_config = "mongodb://#{config.DB_USER}:#{config.DB_PASS}@#{config.DB_HOST}:#{config.DB_PORT}/#{config.DB_NAME}"
#mongoose.connect db_config
if app.settings.env != 'production'
  db_config = 'mongodb://localhost/manaflood-dev'
  mongoose.connect db_config
else
  db_config = "mongodb://#{config.DB_USER}:#{config.DB_PASS}@#{config.DB_HOST}:#{config.DB_PORT}/#{config.DB_NAME}"
  mongoose.connect db_config

#### View initialization 
# Add Connect Assets.
app.use assets()
# Set the public folder as static assets.
app.use express.static(process.cwd() + '/public')


# Set View Engine.
app.set 'view engine', 'jade'

# [Body parser middleware](http://www.senchalabs.org/connect/middleware-bodyParser.html) parses JSON or XML bodies into `req.body` object
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: config.secret
  store: new mongoStore {url: db_config}

#### Authentication
# Initialize authentication
auth = require './auth'
auth(app)

#### Finalization
# Initialize routes
routes = require './routes'
routes(app)

# Export application object
module.exports = app

