mongoose = require 'mongoose'
troop = require 'mongoose-troop'

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId


listTypes = ['deck', 'set', 'cube', 'draft', 'sealed', 'misc']

# Cardlist model
Cardlist = new Schema
  title:
    type: String
    required: true
    match: /[a-zA-Z,\-\/ ']+/
    index:
      unique: true
  author:
    type: ObjectId
    ref: 'User'
  cards:
    type: [
      card:
        type: ObjectId
        ref: 'Card'
      quantity: Number
    ]
    "default": []
  created:
    type: Date
    "default": Date.now
  "public":
    type: Boolean
    "default": true
  type:
    type: String
    "enum": listTypes
    "default": 'misc'
  official:
    type: Boolean
    "default": false


Cardlist.statics.publicFields = publicFields = ['title', 'author', 'cards', 'public', 'type', 'official', '_id']
Cardlist.statics.adminFields = adminFields = []
Cardlist.statics.editableFields = editableFields = ['title', 'cards', 'public', 'type']

Cardlist.virtual('publicView').get ->
  copy = {}
  for field in publicFields
    copy[field] = @[field] if @[field]?
  copy

Cardlist.virtual('adminView').get ->
  copy = @publicView
  for field in adminFields
    copy[field] = @[field] if @[field]?
  copy

Cardlist.statics.publicSearch = (params) ->
  copy = {}
  for field of params
    if field in publicFields
      copy[field] = params[field]
  copy

Cardlist.statics.editable = (cardlist) ->
  newCardlist = {}
  for field in editableFields
    newCardlist[field] = cardlist[field] if cardlist[field]?
  newCardlist

Cardlist.plugin troop.acl

Cardlist.methods.toJSON = ->
  @publicView

module.exports = mongoose.model 'Cardlist', Cardlist