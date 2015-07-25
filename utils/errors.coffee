module.exports = (req, res, next) ->
    req.internalError = (msg) ->
        res.status(500).json err: 'internal', msg: msg || 'Internal error'

    req.badFormatError = (fields, msg) ->
        res.status(400).json err: 'invalid.fields', fields: fields, msg: msg || 'Invalid fields in the request'

    req.notFound = (msg) ->
        res.status(404).json err: 'notfound', msg: msg || 'Invalid data in the request'

    req.invalidRequest = (msg) ->
        res.status(400).json err: 'invalid.request', msg: msg || 'Invalid request'

    req.invalidCredentials = (msg) ->
        res.status(401).json err: 'invalid.credentials', msg: msg || 'Invalid credentials'

    req.resourceConflict = (msg) ->
        res.status(409).json msg: msg || 'Conflict with already existent resource'

    next()