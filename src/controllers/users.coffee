User = require '../models/user'

# User model's CRUD controller.
module.exports = 

  # Lists all users
  index: (req, res) ->
    User.find {}, (err, users) ->
      res.send users.map(publicize)
      
  # Creates new user with data from `req.body`
  create: (req, res) ->
    user = new User req.body
    user.addAccess 'update:' + user._id
    user.addAccess 'delete:' + user._id
    user.save (err, user) ->
      if not err
        res.send publicize(user)
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500
        
  # Gets user by id
  get: (req, res) ->
    User.findById req.params.id, (err, user) ->
      if not err
        res.send publicize(user)
      else
        res.send err
        res.statusCode = 500
             
  # Updates user with data from `req.body`
  update: (req, res) ->
    if req.user?
      isAllowed req.params.id, req.user._id, 'update', (err, allowed) ->
        if allowed
          User.findByIdAndUpdate req.params.id, {"$set":req.body}, (err, user) ->
            unless err?
              return res.send publicize(user)
            else
              return res.send 500, err
        else
          return res.send 401, 'You are not authorized to do that'
    else
      return res.send 401, 'Login required'

  # Deletes user by id
  delete: (req, res) ->
    if req.user?
      isAllowed req.params.id, req.user._id, 'delete', (err, allowed) ->
        if allowed
          User.findByIdAndRemove req.params.id, (err) ->
            if not err
              return res.send {}
            else
              return res.send 500, err
        else
          return res.send 401, 'You are not authorized to do that'
    else
      return res.send 401, 'Login required'

isAllowed = (objectId, userId, permission, next) ->
  User.findById objectId, (err, object) ->
    return next err if err?
    return next null, true if object? and object.access permission + ':' + userId
    return next null, false


publicize = (user) ->
  user.publicView