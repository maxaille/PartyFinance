Party = require '../models/Party'

formatParty = (party, formatUser) ->
    result =
        id: party.id
        name: party.name
        description: party.description
        expenses: (name: e.name, cost: e.cost, to: e.to for e in party.expenses) if party.expenses
        participants: (name: p.name, User: p.User, expenses: p.expenses for p in party.participants) if party.participants
    if result.participants
        for p in result.participants
            if p.User._id
                console.log p.User.username
                p.User = formatUser p.User
    return result

validateParty = (party) ->
    invalidFields = []
    if !party.name or party.name == '' then invalidFields.push 'name'

    if invalidFields.length > 0 then return invalidFields
    else return true

routes =
    '/parties/:id?/:arg?': [
        type: 'get'
        requireAuth: true
        fn: (req, res) ->
            where = {}
            if req.params and req.params.id then where._id = req.params.id
            else if req.query.user then where = participants: $elemMatch: User: req.query.user
            else if req.query and Object.getOwnPropertyNames(req.query).length > 0 then where = req.query

            cb = (err, resultat) ->
                if err
                    if err.name == 'CastError' then return req.notFound()
                    else return req.internalError()
                if where._id
                    if resultat._id then return res.json formatParty(resultat, req.formatUser)
                    else return req.notFound()

                res.json (formatParty party for party in resultat)

            if where._id
                Party.findOne where
                .populate 'participants.User'
                .exec cb
            else
                Party.find where, cb
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
    ,
        type: 'put'
        requireAuth: true
        fn: (req, res) ->
            if !req.params.id then return req.invalidRequest()

            data = formatParty req.body

            Party.find _id: req.params.id, (err, parties) ->
                if err
                    if err.name == 'CastError' then return req.notFound()
                    else return req.internalError()

                if parties.length != 1
                    return req.notFound()
                else
                    party = parties[0]
                    party[key] = value for key, value of data when key != 'id' and value?
                    party.save (err) ->
                        if err then return req.internalError 'Database error'
                        res.send formatParty party
    ]

module.exports = routes