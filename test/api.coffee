should = require 'should'
request = require 'supertest'
jwt = require 'jwt-simple'

if !process.env.MONGO_DATABASE then process.env.MONGO_DATABASE = 'PartyFinance-test'

app = require '../app'
config = require '../config'

# USER configuration
User = require '../models/User'
userTest = username: 'test', password: 'testpwd', email: 'test@test'
userTestId = null
token = ''
expiredToken = ''

usersList = []
usersList.push userTest

# PARTY configuration
Party = require '../models/Party'
partyTest =
    name: 'test'
    description: 'Party test'
    participants: [
        #User: type: mongoose.Schema.Types.ObjectId, ref: 'User'
        name: 'Maxaille'
        expenses: ['sound system', 'beer']
    ]
    expenses: [
        name: 'sound system', cost: 1337,
        name: 'beer', cost: 42,
    ]
partyTestId = null

partiesList = []
partiesList.push partyTest


describe '/api/users', ->
    describe 'POST', ->
        before (done) ->
            User.find().remove done

        it 'should create an user', (done) ->
            request app
            .post '/api/users'
            .send userTest
            .expect 200, (err, res) ->
                if err then done(err)
                User.findOne username: userTest.username, (err, user) ->
                    if err then return done(err)

                    user.username.should.be.equal userTest.username
                    user.verifyPassword userTest.password, (err, isMatch) ->
                        if err then return done err
                        isMatch.should.be.equal true
                        userTestId = user.id
                        done()

        it 'should return a conflict', (done) ->
            request app
            .post '/api/users'
            .send userTest
            .expect 409, done

        it 'should return fields error', (done) ->
            request app
            .post '/api/users'
            .send username: '', password: ''
            .expect 400, (err, res) ->
                if err then return done err
                res.body.fields.should.containEql 'username'
                res.body.fields.should.containEql 'password'
                done()

    describe 'GET', ->
        it 'should not get authorized without token', (done) ->
            request app
            .get '/api/users'
            .expect 401, done

        describe 'With token', ->
            beforeEach (done) ->
                User.findOne username: userTest.username, (err, user) ->
                    if err then return done err

                    payload =
                        id: user.id
                        username: user.username
                        isd: Math.floor Date.now() / 1000
                        exp: Math.floor (Date.now() + 2000)/1000 # Use a delay of 2s before expiration, for test
                    token = jwt.encode payload, config.tokenSecret, 'HS256'

                    expiredPayload =
                        id: user.id
                        username: user.username
                        isd: Math.floor Date.now() / 1000
                        exp: Math.floor (Date.now() - 5000)/1000  # Set the expiration date 5 seconds before its creation date
                    expiredToken = jwt.encode expiredPayload, config.tokenSecret, 'HS256'
                    done()

            it 'should not get authorized with expired token', (done) ->
                request app
                .get '/api/users'
                .set 'authorization', 'Bearer ' + expiredToken
                .expect 401, done

            it 'should receive json data', (done) ->
                request app
                .get '/api/users'
                .set 'authorization', 'Bearer ' + token
                .expect 'Content-Type', /application\/json/
                .expect 200, (err, res) ->
                    if err then return done err
                    res.body.length.should.be.equal usersList.length
                    done()

describe '/api/users/:id', ->
    describe 'GET', ->
        it 'should receive an user', (done) ->
            request app
            .get '/api/users/' + userTestId
            .set 'authorization', 'Bearer ' + token
            .expect 'Content-Type', /application\/json/
            .expect 200, (err, res) ->
                if err then return done err
                res.body.should.be.type 'object'
                done()

        it 'should give a "not found" error with invalid id', (done) ->
            request app
            .get '/api/users/LAMA'
            .set 'authorization', 'Bearer ' + token
            .expect 'Content-Type', /application\/json/
            .expect 404, (err, res) ->
                if err then return done err
                res.body.err.should.be.equal 'notfound'
                done()

        it 'should give a "not found" error with non-existent id', (done) ->
            request app
            .get '/api/users/$2a$05$s8jOd7Tvwc3oGhGORdrKYeMNHXHVogI4sK1Or3jVb11LKqsQedEpW'
            .set 'authorization', 'Bearer ' + token
            .expect 'Content-Type', /application\/json/
            .expect 404, (err, res) ->
                if err then return done err
                res.body.err.should.be.equal 'notfound'
                done()

    describe 'POST', ->
        it 'should not be a valid request', (done) ->
            request app
            .post '/api/users/' + userTestId
            .set 'authorization', 'Bearer ' + token
            .expect 400, done


describe '/api/parties', ->
    describe 'POST', ->
        before (done) ->
            Party.find().remove done

        it 'should not get authorized without token', (done) ->
            request app
            .get '/api/parties'
            .expect 401, done


        describe 'With token', ->
            beforeEach (done) ->
                User.findOne username: userTest.username, (err, user) ->
                    if err then return done err

                    payload =
                        id: user.id
                        username: user.username
                        isd: Math.floor Date.now() / 1000
                        exp: Math.floor (Date.now() + 2000)/1000 # Use a delay of 2s before expiration, for test
                    token = jwt.encode payload, config.tokenSecret, 'HS256'
                    done()


            it 'should create a party', (done) ->
                request app
                .post '/api/parties'
                .set 'authorization', 'Bearer ' + token
                .send partyTest
                .expect 200, (err, res) ->
                    if err then done(err)
                    Party.findOne name: partyTest.name, (err, party) ->
                        if err then return done(err)
                        partyTestId = party.id
                        party.name.should.be.equal partyTest.name
                        done()

            it 'should return fields error', (done) ->
                request app
                .post '/api/parties'
                .set 'authorization', 'Bearer ' + token
                .send name: '', description: 'LAMALAMA'
                .expect 400, (err, res) ->
                    if err then return done err
                    res.body.fields.should.containEql 'name'
                    done()

    describe 'GET', ->
        it 'should not get authorized without token', (done) ->
            request app
            .get '/api/parties'
            .expect 401, done

        describe 'With token', ->
            beforeEach (done) ->
                User.findOne username: userTest.username, (err, user) ->
                    if err then return done err

                    payload =
                        id: user.id
                        username: user.username
                        isd: Math.floor Date.now() / 1000
                        exp: Math.floor (Date.now() + 2000)/1000 # Use a delay of 2s before expiration, for test
                    token = jwt.encode payload, config.tokenSecret, 'HS256'
                    done()

            it 'should receive json data', (done) ->
                request app
                .get '/api/parties'
                .set 'authorization', 'Bearer ' + token
                .expect 'Content-Type', /application\/json/
                .expect 200, (err, res) ->
                    if err then return done err
                    parties = res.body
                    parties.length.should.be.equal partiesList.length
                    firstParty = parties[0]
                    delete firstParty.id # check for equality with sent object, so without id
                    firstParty.should.have.properties partyTest
                    done()

describe '/api/parties/:id', ->
    describe 'GET', ->
        it 'should receive a party', (done) ->
            request app
            .get '/api/parties/' + partyTestId
            .set 'authorization', 'Bearer ' + token
            .expect 'Content-Type', /application\/json/
            .expect 200, (err, res) ->
                if err then return done err
                res.body.should.be.type 'object'
                done()

        it 'should give a "not found" error with invalid id', (done) ->
            request app
            .get '/api/parties/LAMA'
            .set 'authorization', 'Bearer ' + token
            .expect 'Content-Type', /application\/json/
            .expect 404, (err, res) ->
                if err then return done err
                res.body.err.should.be.equal 'notfound'
                done()

        it 'should give a "not found" error with non-existent id', (done) ->
            request app
            .get '/api/parties/$2a$05$s8jOd7Tvwc3oGhGORdrKYeMNHXHVogI4sK1Or3jVb11LKqsQedEpW'
            .set 'authorization', 'Bearer ' + token
            .expect 'Content-Type', /application\/json/
            .expect 404, (err, res) ->
                if err then return done err
                res.body.err.should.be.equal 'notfound'
                done()

    describe 'POST', ->
        it 'should not be a valid request', (done) ->
            request app
            .post '/api/parties/' + partyTestId
            .set 'authorization', 'Bearer ' + token
            .expect 400, done