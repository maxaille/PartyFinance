User = require '../models/User'

# Take an array of Objects
# You can chain same type routes using a new object for middleware for example
#
# Object format:
# 'type': (req, res, next) ->
#
# ex: 'get': (req, res, next) -> next()
#
# or
#
# type: 'type'
# fn: (req, res, next) ->
# (opt) requireAuth: bool
#
# ex:
#   type: 'get'
#   requireAuth: true
#   fn: (req, res, next) ->
#       User.find (err, users) ->
#           if err then return res.send err
#           res.json users
routes =
    '/users/:id?': [
        'get': (req, res, next) ->
            if process.env.MODE == 'DEBUG'
                console.info 'Users list requested'
                console.info req.user
            next()
    ,
        type: 'get'
        requireAuth: true
        fn: (req, res) ->
            where = {}
            if req.params and req.params.id then where._id = req.params.id
            else if req.query and Object.getOwnPropertyNames(req.query).length > 0 then where = req.formatUser req.query

            User.find where, (err, users) ->
                if err
                    if err.name == 'CastError' then return req.notFound()
                    else return req.internalError()
                if where._id
                    if users.length > 0 then return res.json req.formatUser users[0]
                    else return req.notFound()

                res.json (req.formatUser user for user in users)
    ,
        type: 'post'
        fn: (req, res) ->
            if req.params.id then return req.invalidRequest()

            result = req.validateUser req.body
            if result != true then return req.badFormatError result

            user =
                username: req.body.username
                password: req.body.password
                email: req.body.email

            User.findOne username: user.username, (err, resUser) ->
                if err then return req.internalError 'Database error'
                if resUser then return req.resourceConflict 'Username already exist'

                newUser = new User user
                newUser.save (err) ->
                    if err then return req.internalError 'Database error'
                    res.send req.formatUser newUser
    ]

module.exports = routes