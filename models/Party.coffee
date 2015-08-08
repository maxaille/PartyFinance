mongoose = require 'mongoose'
bcrypt = require 'bcrypt-nodejs'
User = require('./User')

PartySchema = new mongoose.Schema
    name: String
    description: String
    participants: [type: mongoose.Schema.Types.ObjectId, ref: 'user']
    expenses: [
        name: String
        cost: Number
        to: type: mongoose.Schema.Types.ObjectId, ref: 'user'
        participants: [
            user: type: mongoose.Schema.Types.ObjectId, ref: 'user'
            paid: Number
        ]
    ]

module.exports = mongoose.model 'party', PartySchema