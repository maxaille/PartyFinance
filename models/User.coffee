mongoose = require 'mongoose'
bcrypt = require 'bcrypt-nodejs'

UserSchema = new mongoose.Schema
    username:
        type: String
        required: true
        unique: true
    email:
        type: String
        required: true
        unique: true
    password:
        type: String
        required: true

checkPasswordModification = (callback) ->
    user = this
    return callback unless user.isModified 'password'

    bcrypt.genSalt 10, (err, salt) ->
        if err then return callback err

        bcrypt.hash user.password, salt, null, (err, hash) ->
            if err then return callback err
            user.password = hash
            callback()

UserSchema.pre 'update', checkPasswordModification
UserSchema.pre 'save', checkPasswordModification

UserSchema.method 'verifyPassword', (password, cb) ->
    bcrypt.compare password, this.password, (err, isMatch) ->
        if err then return cb err
        cb null, isMatch

module.exports = mongoose.model 'user', UserSchema