mongoose = require 'mongoose'
crypto = require 'crypto'
troop = require 'mongoose-troop'

publicFields = ['username', 'online', '_id']

# User model
userSchema =
  email:
    type: String
    match: /[a-z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-z0-9-]+(\.[a-z0-9-]+)*/
    index:
      unique: true
    required: true
  username:
    type: String
    match: /[a-zA-Z][a-zA-Z0-9]{4,}/
    index:
      unique: true
    required: true
  hashed_password:
    type: String
  salt:
    type: String
  dateCreated:
    type: Date
    "default": Date.now
  lastLogin:
    type: Date
    "default": Date.now
  online:
    type: Boolean
    "default": false
  roles:
    type: [String]

User = new mongoose.Schema userSchema

User.virtual('password').set((password) ->
  @_password = password
  @salt = do @makeSalt
  @hashed_password = @encryptPassword password
).get ->
  @_password

User.method 'encryptPassword', (password) ->
  crypto.createHmac('sha1', @salt).update(password).digest 'hex'

User.method 'authenticate', (plainText) ->
  @encryptPassword(plainText) is @hashed_password

User.method 'makeSalt', ->
  Math.round(new Date().valueOf() * Math.random()) + ''

User.method 'markLogin', () ->
  @lastLogin = Date.now()
  @online = true

User.method 'markLogout', () ->
  @online = false

User.statics.publicFields = publicFields
User.statics.adminFields = adminFields = ['email']
User.statics.updateableFields = editableFields = ['username', 'email', 'password']

User.virtual('adminView').get ->
  copy = @publicView
  for field in adminFields
    copy[field] = @[field] if @[field]?
  copy

User.virtual('publicView').get ->
  copy = {}
  for field in publicFields
    copy[field] = @[field] if @[field]?
  copy

User.statics.publicSearch = (params) ->
  copy = {}
  for field of params
    if field in publicFields
      copy[field] = params[field]
  copy

User.statics.editable = (user) ->
  newUser = {}
  for field in editableFields
    newUser[field] = user[field] if user[field]?
  newUser

User.plugin troop.acl

User.methods.toJSON = ->
  @publicView

module.exports = mongoose.model 'User', User