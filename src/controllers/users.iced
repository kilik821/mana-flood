User = require '../models/user'

# User model's CRUD controller.
module.exports = 

  # Lists all users
  index: (req, res) ->
    where = User.publicSearch req.whereParams
    User.find where, req.searchFields, req.searchOptions, (err, users) ->
      res.send users.map(publicize)
      
  # Creates new user with data from `req.body`
  create: (req, res) ->
    user = new User User.editable req.body
    user.addAccess 'update:' + user._id
    user.addAccess 'delete:' + user._id
    user.save (err, user) ->
      unless err?
        res.send 201, publicize(user)
      else res.send 500, err

  # Gets user by id
  get: (req, res) ->
    User.findById req.params.id, req.searchFields, (err, user) ->
      unless err?
        if user?
          res.send publicize(user)
        else res.send 404
      else res.send 500, err

  # Updates user with data from `req.body`
  update: (req, res) ->
    if req.user?
      isAllowed req.params.id, req.user._id, 'update', (err, allowed) ->
        if allowed
          User.findByIdAndUpdate req.params.id, {"$set":User.editable req.body}, (err, user) ->
            unless err?
              res.send publicize(user)
            else res.send 500, err
        else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

  # Deletes user by id
  delete: (req, res) ->
    if req.user?
      isAllowed req.params.id, req.user._id, 'delete', (err, allowed) ->
        if allowed
          User.findByIdAndRemove req.params.id, (err) ->
            if not err
              res.send {}
            else res.send 500, err
        else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

  currentUser: (req, res) ->
    if req.user?
      res.send publicize(req.user)
    else res.send 404

  addUserRole: (req, res) ->
    if req.user?
      if 'editUserRoles' in req.user.roles
        if req.query.role?
          User.findByIdAndUpdate req.params.id, {$addToSet: {roles: req.query.role}}, (err) ->
            unless err?
              res.send 200
            else res.send 500, err
        else res.send 400, 'Requries role query'
      else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

  removeUserRole: (req, res) ->
    if req.user?
      if 'editUserRoles' in req.user.roles
        if req.query.role?
          User.findById req.params.id, (err, user) ->
            unless err?
              user.roles.remove req.query.role
              user.save (err) ->
                unless err?
                  res.send 200
                else res.send 500, err
            else res.send 500, err
        else res.send 400, 'Requries role query'
      else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

isAllowed = (objectId, userId, permission, next) ->
  User.findById objectId, (err, object) ->
    return next err if err?
    return next null, true if object? and object.access permission + ':' + userId
    return next null, false

publicize = (object) ->
  if object? then object.publicView ? {} else null