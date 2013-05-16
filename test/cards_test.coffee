request = require 'supertest'

Card = require process.cwd() + '/.app/models/card'
app = require process.cwd() + '/.app'


INITIAL_DATA = {
  "someField":"Some Data"
}

UPDATED_DATA = {
  "someField":"Another data"
}

cleanDB = (done) ->
  Card.remove {}, ->
    done()

describe 'Card', ->
  before cleanDB
  
  card_id = null
      
  it "should be created", (done) ->
    request(app)
      .post("/api/cards")
      .send(INITIAL_DATA)
      .expect 201, (err, res) ->
        res.body.should.include(INITIAL_DATA)
        res.body.should.have.property "_id"
        res.body["_id"].should.be.ok
        card_id = res.body["_id"]
        done()
        
  it "should be accessible by id", (done) ->
    request(app)
      .get("/api/cards/#{card_id}")
      .expect 200, (err, res) ->
        res.body.should.include(INITIAL_DATA)
        res.body.should.have.property "_id"
        res.body["_id"].should.be.eql card_id
        done()
        
  it "should be listed in list", (done) ->
    request(app)
      .get("/api/cards")
      .expect 200, (err, res) ->
        res.body.should.be.an.instanceof Array
        res.body.should.have.length 1
        res.body[0].should.include(INITIAL_DATA)
        done()
    
  it "should be updated", (done) ->
    request(app)
      .put("/api/cards/#{card_id}")
      .send(UPDATED_DATA)
      .expect 200, (err, res) ->
        res.body.should.include(UPDATED_DATA)
        done()
        
  it "should be persisted after update", (done) ->
    request(app)
      .get("/api/cards/#{card_id}")
      .expect 200, (err, res) ->
        res.body.should.include(UPDATED_DATA)
        res.body.should.have.property "_id"
        res.body["_id"].should.be.eql card_id
        done()
  
  it "should be removed", (done) ->
    request(app)
      .del("/api/cards/#{card_id}")
      .expect 200, (err, res) ->
        done()
    
  it "should not be listed after remove", (done) ->
    request(app)
      .get("/api/cards")
      .expect 200, (err, res) ->
        res.body.should.be.an.instanceof Array
        res.body.should.have.length 0
        done()
        
  after cleanDB
      