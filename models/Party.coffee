mongoose = require 'mongoose'
bcrypt = require 'bcrypt-nodejs'
User = require('./User').schema

PartySchema = new mongoose.Schema
    name: String
    description: String
    participants: [
        User: type: mongoose.Schema.Types.ObjectId, ref: 'User'
        name: String
        expenses: [String]
        paid: Number
    ]
    expenses: [name: String, cost: Number, to: type: mongoose.Schema.Types.ObjectId, ref: 'User']

module.exports = mongoose.model 'party', PartySchema