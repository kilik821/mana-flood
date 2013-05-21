maintaining = false
maintenance = null

# Maintenances meant to be done
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

cardListUpdate = (sets, cb) ->
  console.log 'Started card list update'

  cardlistModel = require './models/cardlist'
  cardModel = require './models/card'

  updating = true
  tutor = require 'tutor'
  await tutor.sets defer err, officialSets
  unless sets?
    sets = officialSets
  for setName in sets
    if setName in officialSets
      setList =
        title: setName
        "public": true
        type: 'set'
        official: true
      await cardlistModel.findOneAndUpdate {title: setName}, {$set: setList}, {upsert: true}, defer err, newSetList
      if err? console.log err
      else
        await tutor.set newSetList.title, defer err, cards
        return cb err if err?
        errors = []
        createdCards = []
        await
          for card,i in cards
            newCard =
              name: card.name ? undefined
              convertedManaCost: card.converted_mana_cost ? undefined
              superTypes: card.supertypes ? undefined
              types: card.types ? undefined
              subTypes: card.subtypes ? undefined
              expansion: newSetList.id ? undefined
              expansionName: card.expansion ? undefined
              gathererUrl: card.gatherer_url ? undefined
              imageUrl: card.image_url ? undefined
              manaCost: card.mana_cost ? undefined
              text: card.text ? undefined
              rarity: card.rarity ? undefined
              power: card.power ? undefined
              toughness: card.toughness ? undefined
              "public": true
              official: true
              versions: []
            for versionSet, rarity of card.versions
              newCard.versions.push {setName: versionSet, rarity: rarity}
            for key, val of newCard
              unless val?
                delete newCard[key]
            cardModel.findOneAndUpdate {name: newCard.name, expansion: newCard.expansion}, {$set: newCard}, {upsert: true}, defer errors[i], createdCards[i]
        for error in errors
          console.log error if error?
        for createdCard in createdCards
          if createdCard.id not in newSetList.cards
            newSetList.cards.addToSet {card: createdCard.id}
            newSetList.save ->
        console.log "Did set #{setName}."
    else
      return cb new Error("Set #{setName} not an official set.")
  return cb null, 'Successfully updated card list.'

exports.scheduleCardListUpdate = (interval, cb) ->
  update = setInterval () ->
    cardListUpdate cb
  , interval

exports.manualCardListUpdate = (sets, cb) ->
  unless updating
    cardListUpdate sets, (err, result) ->
      updating = false
      return cb err, result
  else
    cb new Error 'Maintenance in progress.'

exports.manualAllCardListUpdate = (cb) ->
  await require('tutor').sets defer err, sets
  for set in sets
    await cardListUpdate [set], defer err, result
    if err?
      return cb err
  return cb null, 'Updated all card lists.'