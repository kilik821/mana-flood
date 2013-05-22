updates = require '../update'

module.exports =

  # Perform updates if user has update permission
  cardList: (req, res) ->
    if req.user?
      if 'updateDatabase' in req.user.roles
        if req.query.sets? and req.query.sets is 'all'
          updates.manualAllCardListUpdate (err, result) ->
            return res.send 500, err if err?
            console.log result
            return res.send 200, result
        else if req.query.start?
          updates.manualStartAtCardListUpdate req.query.start, (err, result) ->
            return res.send 500, err if err?
            console.log result
            return res.send 200, result
        else
          updates.manualCardListUpdate req.query.sets?.split(','), (err, result) ->
            return res.send 500, err if err?
            console.log result
            return res.send 200, result
      else res.send 401, 'Unauthorized'
    else res.send 401, 'Login required'