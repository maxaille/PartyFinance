module.exports = (app) ->
    app.get '*', (req, res, next) ->
        if req.query.where
            try
                req.where = JSON.parse req.query.where
            catch e
        next()
    return app