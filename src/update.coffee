maintaining = false
maintenance = null

# Maintenances meant to be done on
doMaintenance = (cb) ->



exports.scheduleMaintenance = (interval, cb) ->
  maintenance = setInterval () ->
    doMaintenance cb
  , interval
  console.log "Scheduled maintenance every #{interval} seconds."

exports.manualMaintenance = (cb) ->
  unless maintaining
    doMaintenance cb
  else
    cb new Error 'Maintenance in progress.'

updating = false
update = null

cardListUpdate = (cb) ->
  cardlistModel = require './models/cardlist'
  cardModel = require './models/card'

  updating = true
  tutor = require 'tutor'
  tutor.sets (err, setNames) ->
    setNames.slice(0,1).forEach (setName) ->
      setList =
        title: setName
        "public": true
        type: 'set'
      cardlistModel.findOneAndUpdate {title: setName}, {$set: setList}, {upsert: true}, (err, newSetList) ->
        if err? console.log err
        else
          console.log "Created/updated set #{newSetList.title}."
          tutor.set newSetList.title, (err, cards) ->
            if err?
              return cb err
            cards.forEach (card) ->
              if card?
                newCard =
                  name: card.name ? undefined
                  convertedManaCost: card.converted_mana_cost ? undefined
                  superTypes: card.supertypes ? undefined
                  types: card.types ? undefined
                  subTypes: card.subtypes ? undefined
                  expansion: newSetList.id ? undefined
                  gathererUrl: card.gatherer_url ? undefined
                  imageUrl: card.image_url ? undefined
                  manaCost: card.mana_cost ? undefined
                  text: card.text ? undefined
                  rarity: card.rarity ? undefined
                  power: card.power ? undefined
                  toughness: card.toughness ? undefined
                  versions: []
                for versionSet, rarity of card.versions
                  newCard.versions.push {setName: versionSet, rarity: rarity}
                for key, val of newCard
                  unless val?
                    delete newCard[key]
                cardModel.findOneAndUpdate {name: newCard.name, expansion: newCard.expansion}, {$set: newCard}, {upsert: true}, (err, createdCard) ->
                  if err?
                    return cb err
                  else
                    newSetList.cards.push {card: createdCard.id}
                    newSetList.save (err) ->
                      return cb err, createdCard

exports.scheduleCardListUpdate = (interval, cb) ->
  update = setInterval () ->
    cardListUpdate cb
  , interval

exports.manualCardListUpdate = (cb) ->
  unless updating
    cardListUpdate cb
  else
    cb new Error 'Maintenance in progress.'