Card = require '../models/card'

# Card model's CRUD controller.
module.exports =

# Lists all cards
  index: (req, res) ->
    req.whereParams.public = true
    where = Card.publicSearch req.whereParams
    Card.find where, req.searchFields, req.searchOptions, (err, cards) ->
      res.send cards.map(publicize)

  # Creates new card with data from `req.body`
  create: (req, res) ->
    if req.user?
      userId = req.user._id
      card = new Card Card.editable req.body
      card.addAccess 'view:' + userId
      card.addAccess 'update:' + userId
      card.addAccess 'delete:' + userId
      card.save (err, card) ->
        unless err?
          res.send 201, publicize(card)
        else res.send 500, err
    else res.send 401, 'Login required'

  # Gets card by id
  get: (req, res) ->
    Card.findById req.params.id, req.searchFields, (err, card) ->
      unless err?
        if card.public or card.access 'view:' + req.user?._id
          res.send publicize(card)
        else res.send 404
      else res.send 500, err

  # Updates card with data from `req.body`
  update: (req, res) ->
    if req.user?
      isAllowed req.user._id, req.params.id, 'update', (err, allowed) ->
        if allowed
          Card.findByIdAndUpdate req.params.id, {"$set": Card.editable(req.body)}, (err, card) ->
            unless err?
              res.send publicize(card)
            else res.send 500, err
        else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

  # Deletes card by id
  delete: (req, res) ->
    if req.user?
      isAllowed req.user._id, req.params.id, 'delete', (err, allowed) ->
        if allowed
          Card.findByIdAndRemove req.params.id, (err) ->
            unless err?
              res.send 200
            else
              res.send 500, err
        else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'

isAllowed = (objectId, userId, permission, next) ->
  Card.findById objectId, (err, object) ->
    return next err if err?
    return next null, true if object? and object.access permission + ':' + userId
    return next null, false

publicize = (object) ->
  object.publicView ? {}