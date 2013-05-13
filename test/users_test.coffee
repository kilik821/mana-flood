request = require 'supertest'

User = require process.cwd() + '/.app/models/user'
app = require process.cwd() + '/.app'


INITIAL_DATA = {
  email: "test@test.com"
  username: "imawesome"
  password: "testpass"
}

INITIAL_PUBLIC =
  username: INITIAL_DATA.username

UPDATED_DATA = {
  email: "test@peen.com"
  username: "imnotawesome"
  password: "test2pass"
}

UPDATED_PUBLIC =
  username: UPDATED_DATA.username

cleanDB = (done) ->
  User.remove {}, ->
    done()

describe 'User', ->
  before cleanDB
  
  user_id = null
      
  it "should be created", (done) ->
    request(app)
      .post("/api/users")
      .send(INITIAL_DATA)
      .expect 201, (err, res) ->
        res.body.should.include(INITIAL_PUBLIC)
        res.body.should.have.property "_id"
        res.body["_id"].should.be.ok
        user_id = res.body["_id"]
        done()
        
  it "should be accessible by id", (done) ->
    request(app)
      .get("/api/users/#{user_id}")
      .expect 200, (err, res) ->
        res.body.should.include(INITIAL_PUBLIC)
        res.body.should.have.property "_id"
        res.body["_id"].should.be.eql user_id
        done()
        
  it "should be listed in list", (done) ->
    request(app)
      .get("/api/users")
      .expect 200, (err, res) ->
        res.body.should.be.an.instanceof Array
        res.body.should.have.length 1
        res.body[0].should.include(INITIAL_PUBLIC)
        done()
    
  it "should be updated", (done) ->
    request(app)
      .put("/api/users/#{user_id}")
      .send(UPDATED_DATA)
      .expect 200, (err, res) ->
        res.body.should.include(UPDATED_PUBLIC)
        done()
        
  it "should be persisted after update", (done) ->
    request(app)
      .get("/api/users/#{user_id}")
      .expect 200, (err, res) ->
        res.body.should.include(UPDATED_PUBLIC)
        res.body.should.have.property "_id"
        res.body["_id"].should.be.eql user_id
        done()
  
  it "should be removed", (done) ->
    request(app)
      .del("/api/users/#{user_id}")
      .expect 200, (err, res) ->
        done()
    
  it "should not be listed after remove", (done) ->
    request(app)
      .get("/api/users")
      .expect 200, (err, res) ->
        res.body.should.be.an.instanceof Array
        res.body.should.have.length 0
        done()
        
  after cleanDB
      