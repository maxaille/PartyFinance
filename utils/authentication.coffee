jwt = require 'jwt-simple'
mongoose = require 'mongoose'

User = require '../models/User'
config = require '../config'

generateToken = (user) ->
    payload =
        id: user.id
        username: user.username
        isd: Math.floor Date.now() / 1000
        exp: Math.floor (Date.now() + config.tokenExpirationDelay)/1000
    return jwt.encode payload, config.tokenSecret, 'HS256'

formatUser = (user) ->
    result =
        id: user._id
        username: user.username
    return result

validateUser = (user) ->
    invalidFields = []
    if !user.username or user.username.length < 3 then invalidFields.push 'username'
    if !user.password or user.password.length < 3 then invalidFields.push 'password'

    if invalidFields.length > 0 then return invalidFields
    else return true

module.exports = (app) ->
    app.use (req, res, next) ->
        req.formatUser = formatUser
        req.validateUser = validateUser
        next()
    # Handle authentication
    app.post '/login', (req, res) ->
        result = validateUser req.body
        if result != true then return req.badFormatError result

        User.findOne username: req.body.username, (err, user) ->
            if err then return req.internalError msg: 'Database error'
            if !user then return req.invalidCredentials()

            user.verifyPassword req.body.password, (err, isMatch) ->
                if err then return req.internalError msg: 'Failed to check password'
                if isMatch
                    token = generateToken user
                    result =
                        user: formatUser user
                        token: token
                        exp: Math.floor (Date.now() + config.tokenExpirationDelay)/1000
                    res.json result
                else
                    req.invalidCredentials()
    return app