Party = require '../models/Party'

formatParty = (party) ->
    result =
        id: party.id
        name: party.name
        description: party.description
        expenses: (name: e.name, cost: e.cost for e in party.expenses)
        participants: (name: p.name, User: p.User, expenses: p.expenses for p in party.participants)
    return result

validateParty = (party) ->
    invalidFields = []
    if !party.name or party.name == '' then invalidFields.push 'name'

    if invalidFields.length > 0 then return invalidFields
    else return true

routes =
    '/parties/:id?': [
        type: 'get'
        requireAuth: true
        fn: (req, res) ->
            where = if req.params and req.params.id then _id: req.params.id else {}

            Party.find where, (err, parties) ->
                if err
                    if err.name == 'CastError' then return req.notFound()
                    else return req.internalError()
                if where._id
                    if parties.length > 0 then return res.json formatParty parties[0]
                    else return req.notFound()

                res.json (formatParty party for party in parties)
    ,
        type: 'post'
        requireAuth: true
        fn: (req, res) ->
            if req.params.id then return req.invalidRequest()

            result = validateParty req.body
            if result != true then return req.badFormatError result

            party =
                name: req.body.name
                description: req.body.description
                participants: req.body.participants
                expenses: req.body.expenses

            newParty = new Party party
            newParty.save (err) ->
                if err then return req.internalError 'Database error'
                res.send formatParty newParty
    ]

module.exports = routes