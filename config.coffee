module.exports =
    port: 3000
    HTTPS_port: 3001

    mongoUrl: 'localhost'
    mongoPort: 27017
    mongoDatabase: 'PartyFinance'
    mongoUser: ''
    mongoPassword: ''

    tokenSecret: 'YOU SHALL NOT DECODE' # IMPORTANT: to change !!
    tokenExpirationDelay: 60*60*1000