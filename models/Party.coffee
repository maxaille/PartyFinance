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
    ]
    expenses: [name: String, cost: Number]

module.exports = mongoose.model 'party', PartySchema