should = require 'should'
request = require 'supertest'

app = require '../app'

describe 'index', ->
    it 'should respond with the index in html', (done) ->
        request app
        .get '/'
        .expect 'Content-Type', /text\/html/
        .expect 200, done
