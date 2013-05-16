updates = require '../update'

module.exports =

  # Perform updates if user has update permission
  cardList: (req, res) ->
    if req.user? and ['updateDatabase'] in req.user.roles
      updates.manualCardListUpdate (err, result) ->
        unless err?
          res.send result
        else
          res.send 500, err