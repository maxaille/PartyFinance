fs = require 'fs'
console = require 'better-console'
express = require 'express'
require 'express-template-cache' # Use cache for generating the index only once
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
bodyParser = require 'body-parser'
jwt = require 'jwt-simple'

conf = require './config'

app = express()

# *********** DB ***********
mongoose = require 'mongoose'
mgCf =
    user: process.env.MONGO_USER || conf.mongoUser || ''
    password: process.env.MONGO_PASSWORD || conf.mongoPassword || ''
    url: process.env.MONGO_URL || conf.mongoUrl || 'localhost'
    port: process.env.MONGO_PORT || conf.mongoPort || '27017'
    database: process.env.MONGO_DATABASE || conf.mongoDatabase || 'Secure-MEAN'
mongoose.connect "mongodb://#{mgCf.user}#{if !!mgCf.password and !!mgCf.user then ':' + mgCf.password else ''}#{if !!mgCf.user then '@' else ''}#{mgCf.url}#{if !!mgCf.port then ':' + mgCf.port else ''}/#{mgCf.database}"
mongoose.connection.once 'open', ->
    console.info 'DB Connected'

# ******* CONFIGURATION *******
app.set 'view engine', 'jade'
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: false

# **** Predefined Errors ****0
# Set some predefined error responses in req
app.use require './utils/errors'

# ********** CORS ************
# Enable request from another domain (HTTPS from HTTP for example)
app.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type,Authorization'

    if req.method == 'OPTIONS' then return res.status(200).send()

    next()

# ********** STATIC  **********
app.use express.static path.join(__dirname, 'public/build')

# ******* AUTHENTICATION *******
app = require('./utils/authentication')(app)

# ******* JWT MIDDLEWARE *******
User = require './models/User'
app.use (req, res, next) ->
    # Check for token in the request
    token = (req.headers['authorization'] && req.headers['authorization'].split('Bearer ')[1]) or # Used in this application
            (req.body && req.body.access_token) or
            (req.query && req.query.access_token) or
            req.headers['access-token']
    if token
        req.user = jwt.decode token, conf.tokenSecret
        req.user.isValid = (cb) ->
            if req.user.exp * 1000 >= Date.now()
                User.findOne id: req.user.id, (err, user) ->
                    if err then cb err
                    else cb null
            else
                cb expired: true
    next()

app.checkJWT = (req, res, next) ->
    if req.user
        req.user.isValid (err) -> if err then res.status(401).send() else next()
    else
        res.status(401).send()

# ******** REST *********
# Load all routes in /controllers
# and check if require authentication with JWT
dir = './controllers'
controllers = []

walk = (dir) ->
    list = fs.readdirSync dir
    list.forEach (file) ->
        file = dir + '/' + file
        stat = fs.statSync file
        if stat && stat.isDirectory()
            walk file
        else
            controllers.push file
walk dir

for file in controllers
    controller = require file
    for route, list of controller
        route = app.route '/api' + route
        for fn in list
            if fn.type
                if fn.requireAuth then route[fn.type] app.checkJWT, fn.fn
                else route[fn.type] fn.fn
            else
                route[Object.keys(fn)[0]] fn[Object.keys(fn)[0]]



# ******* ERRORS ********
# catch 404 and forward to error handler
app.use (req, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

app.use (err, req, res) ->
    err.status = err.status or 500
    res.status err.status
    res.render 'error',
        err: {msg: err.message}

module.exports = app