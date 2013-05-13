mongoose = require 'mongoose'
crypto = require 'crypto'
troop = require 'mongoose-troop'

# User model
validatePresenceOf = (value) ->
  value?

re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
validateEmailRegex = (value) ->
  re.test value

publicFields = ['username', 'online', '_id']
adminFields = publicFields.concat ['email']

userSchema =
  email:
    type: String
    validate:
      [
        {validator: validateEmailRegex, msg: 'Email did not match expected format'}
      ]
    index:
      unique: true
    required: true
  username:
    type: String
    index:
      unique: true
    required: true
  hashed_password:
    type: String
    select: true
  salt:
    type: String
    select: true
  dateCreated:
    type: Date
    "default": Date.now
  lastLogin:
    type: Date
    "default": Date.now
  online:
    type: Boolean
    "default": false

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

User.virtual('adminView').get ->
  copy = {}
  for field in adminFields
    copy[field] = @[field]
  copy

User.virtual('publicView').get ->
  copy = {}
  for field in publicFields
    copy[field] = @[field]
  copy

User.method 'markLogin', () ->
  @lastLogin = Date.now()
  @online = true

User.method 'markLogout', () ->
  @online = false

User.plugin troop.acl

module.exports = mongoose.model 'User', User