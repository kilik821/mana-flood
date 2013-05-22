mongoose = require 'mongoose'
troop = require 'mongoose-troop'

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

# Card model
rarities = ['Uncommon', 'Common', 'Rare', 'Mythic Rare']

Card = new Schema
  name:
    type: String
    required: true
  convertedManaCost: Number
  superTypes:
    type: [
      type: String
    ]
    "default": []
  types:
    type: [
      type: String
    ]
    "default": []
  subTypes:
    type: [
      type: String
    ]
  expansion:
    type: ObjectId
    ref: 'Cardlist'
  expansionName: String
  gathererUrl: String
  imageUrl: String
  manaCost:
    type: String
    "default": ''
  power: String
  toughness: String
  text:
    type: String
    "default": ''
  versions:
    type: [
      setName: String
      rarity:
        type: String
        "enum": rarities
    ]
  rarity:
    type: String
    "enum": rarities
  official:
    type: Boolean
    "default": false
  author:
    type: ObjectId
    ref: 'User'
  "public":
    type: Boolean
    "default": true

Card.statics.publicFields = publicFields = ['name','convertedManaCost','superTypes','types','subTypes','expansion',
                                            'gathererUrl','imageUrl','manaCost','power','toughness','text','versions',
                                            'rarity','official','author']
Card.statics.adminFields = adminFields = []

Card.statics.editableFields = editableFields = ['name','convertedManaCost','superTypes','types','subTypes','imageUrl',
                                                'manaCost','power','toughness','text','rarity']

Card.virtual('publicView').get ->
  copy = {}
  for field in publicFields
    copy[field] = @[field] if @[field]?
  copy

Card.virtual('adminView').get ->
  copy = @publicView
  for field in adminFields
    copy[field] = @[field] if @[field]?
  copy

Card.statics.publicSearch = (params) ->
  copy = {}
  for field of params
    if field in publicFields
      copy[field] = params[field]
  copy

Card.statics.editable = (card) ->
  newCard = {}
  for field in editableFields
    newCard[field] = card[field] if card[field]?
  newCard

module.exports = mongoose.model 'Card', Card