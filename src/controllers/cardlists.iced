Cardlist = require '../models/cardlist'

# Cardlist model's CRUD controller.
module.exports = 

  # Lists all cardlists
  index: (req, res) ->
    req.whereParams.public = true
    where = Cardlist.publicSearch req.whereParams
    Cardlist.find where, req.searchFields, req.searchOptions, (err, cardlists) ->
      Cardlist.populate cardlists, req.populate, (err, cardlists) ->
        res.send cardlists.map(publicize)
      
  # Creates new cardlist with data from `req.body`
  create: (req, res) ->
    if req.user?
      userId = req.user._id
      cardlist = new Cardlist Cardlist.editable req.body
      cardlist.author = userId
      cardlist.addAccess 'view:' + userId
      cardlist.addAccess 'update:' + userId
      cardlist.addAccess 'delete:' + userId
      cardlist.save (err, cardlist) ->
        unless err?
          res.send 201, publicize(cardlist)
        else res.send 500, err
    else res.send 401, 'Login required'
        
  # Gets cardlist by id
  get: (req, res) ->
    Cardlist.findById req.params.id, req.searchFields, (err, cardlist) ->
      unless err?
        if cardlist.public or cardlist.access 'view:' + req.user?._id
          res.send publicize(cardlist)
        else res.send 404
      else res.send 500, err

  # Gets most recent decks
  recentDecks: (req, res) ->
    whereOptions = if req.whereParams? then Cardlist.publicSearch(req.whereParams) else {}
    whereOptions.public = true
    whereOptions.type = 'deck'
    req.searchOptions.sort = {created: -1} if req.searchOptions?
    Cardlist.find Cardlist.publicSearch(req.whereParams), req.searchFields, req.searchOptions, (err, cardlists) ->
      unless err?
        res.send 200, cardlists.map(publicize)
      else
        res.send 500, err

  # Updates cardlist with data from `req.body`
  update: (req, res) ->
    if req.user?
      isAllowed req.user._id, req.params.id, 'update', (err, allowed) ->
        if allowed
          Cardlist.findByIdAndUpdate req.params.id, {"$set":Cardlist.editable(req.body)}, (err, cardlist) ->
            unless err?
              res.send publicize(cardlist)
            else
              res.send 500, err
        else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

  # Deletes cardlist by id
  delete: (req, res) ->
    if req.user?
      isAllowed req.user._id, req.params.id, 'delete', (err, allowed) ->
        if allowed
          Cardlist.findByIdAndRemove req.params.id, (err) ->
            unless err?
              res.send 200
            else res.send 500, err
        else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

isAllowed = (userId, objectId, permission, next) ->
  Cardlist.findById objectId, (err, object) ->
    return next err if err?
    return next null, true if object? and object.access permission + ':' + userId
    return next null, false


publicize = (object) ->
  object.publicView ? {}