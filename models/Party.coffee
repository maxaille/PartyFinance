mongoose = require 'mongoose'
bcrypt = require 'bcrypt-nodejs'
User = require('./User')

PartySchema = new mongoose.Schema
    name: String
    description: String
    participants: [
        User: type: mongoose.Schema.Types.ObjectId, ref: 'user'
        name: String
        expenses: [String]
        paid: Number
    ]
    expenses: [name: String, cost: Number, to: type: mongoose.Schema.Types.ObjectId, ref: 'user']

module.exports = mongoose.model 'party', PartySchema