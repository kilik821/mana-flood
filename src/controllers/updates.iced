updates = require '../update'

module.exports =

  # Perform updates if user has update permission
  cardList: (req, res) ->
    if req.user?
      if 'updateDatabase' in req.user.roles
        updates.manualCardListUpdate (err, result) ->
          res.send 500, err if err?
          console.log result
      else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'