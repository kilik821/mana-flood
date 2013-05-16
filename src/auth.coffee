passport = require 'passport'
User = require './models/user'
LocalStrategy = require('passport-local').Strategy
#### We are setting up authentication through passport for secure sessions

module.exports = (app) ->
  passport.use new LocalStrategy (username, password, done) ->
    User.findOne {username: username}, (err, user) ->
      return done err if err?
      return done null, false, {message: 'Unrecognized username/password combination'} unless user and user.authenticate password
      return done null, user

  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done err, user

  app.use passport.initialize()
  app.use passport.session()

  app.post '/api/users/all/login', (req, res, next) ->
    passport.authenticate('local', (err, user, info) ->
      return next err if err?
      return res.send 401, info.message unless user
      do user.markLogin
      return next err if err?
      req.logIn user, (err) ->
        return next err if err?
        return res.send 200, user.publicView
    )(req, res, next)

  app.get '/api/users/all/logout', (req, res, next) ->
    if req.user?
      do req.user.markLogout
    req.logout()
    res.send 200