should = require 'should'
request = require 'supertest'
jwt = require 'jwt-simple'

if !process.env.MONGO_DATABASE then process.env.MONGO_DATABASE = 'Secure-MEAN-test'

app = require '../app'
config = require '../config'

User = require '../models/User'
userTest = username: 'test', password: 'testpwd'
userTestId = null
token = ''
expiredToken = ''

usersList = []
usersList.push userTest

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
                User.findOne userTest.username, (err, user) ->
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