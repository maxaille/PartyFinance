@App = angular.module "PartyFinance", [
    'ui.router'
    'ngResource'
    'pascalprecht.translate'
]
App.value 'API', location.origin

App.factory 'authInterceptor', [
    '$token'
    'API'
    ($token, API) ->
        request: (config) ->
            token = $token.getToken()
            # Request to an API subroute, add token in headers
            if config.url.indexOf(API) == 0 and new URL(config.url).pathname.indexOf(new URL(API).pathname) == 0 and token
                config.headers.Authorization = 'Bearer ' + token
            return config
        response: (res) ->
            if res.config.url.indexOf(API) == 0 and typeof res.data.token != 'undefined'
                $token.saveToken res.data.token
            return res
]

App.config [
    '$httpProvider'
    ($httpProvider) ->
        $httpProvider.interceptors.push 'authInterceptor'
]

App.config [
    '$translateProvider'
    ($translateProvider) ->
        $translateProvider.useSanitizeValueStrategy 'escaped'
        $translateProvider.useStaticFilesLoader
            'prefix': 'resources/translations/'
            'suffix': '.json'
        $translateProvider.preferredLanguage 'fr'
]

App.service '$token', [
    '$window'
    '$rootScope'
    '$timeout'
    ($window, $rootScope, $timeout) ->
        $token =
            parseJwt: (token) =>
                base64Url = token.split('.')[1];
                base64 = base64Url.replace('-', '+').replace '_', '/'
                return JSON.parse $window.atob base64
            saveToken: (token) =>
                if $token.isValid token
                    $window.localStorage['jwtToken'] = token
                else return false
            getToken: =>
                return $window.localStorage['jwtToken']
            removeToken: =>
                return delete $window.localStorage['jwtToken']
            isValid: (token) =>
                if token
                    parsed = $token.parseJwt token
                    return Math.round(Date.now() / 1000) < parsed.exp
                else return false
]

App.run [
    '$rootScope'
    '$state'
    '$anchorScroll'
    '$location'
    '$http'
    '$token'
    '$window'
    '$timeout'
    'API'
    ($rootScope, $state, $anchorScroll, $location, $http, $token, $window, $timeout, API) ->
        $rootScope.title = $state.current.title
        $rootScope.$http = $http
        $rootScope.$window = $window
        $rootScope.$state = $state
        $rootScope.auth = $token
        $rootScope.$anchorScroll = $anchorScroll

        $rootScope.user = null


        # Set ability to disconnect before expiration
        $rootScope.disconnectUser = ->
            $timeout.cancel $rootScope.timerExpiration
            $token.removeToken()
            $state.go 'start'
            .then ->
                $rootScope.$broadcast 'user:disconnected'

        # Bind some events...
        $rootScope.$on 'user:loggedin', (e, data) ->
            $rootScope.user = data.user

            $rootScope.timerExpiration = $timeout ->
                $rootScope.$broadcast 'user:disconnected'
            , data.exp - Date.now()
            console.log 'User logged in'

        $rootScope.$on 'user:disconnected', ->
            $rootScope.user = null
            # redirect to login if secured state when token expire, saving the old state
            if $state.current.secured == true
                $state.go 'login', oldState: $state.current
            console.log 'User got disconnected'


        # if valid token, request the user from the server
        if token = $token.getToken()
            parsed = $token.parseJwt token
            exp = parsed.exp * 1000
            if $token.isValid(token) and exp - Date.now() > 0
                $rootScope.user = $http.get API + '/api/users/' + parsed.id
                .success (user) ->
                    $rootScope.$broadcast 'user:loggedin', user: user, exp: exp
                .error ->
                    console.log 'invalid user ?'
            else $token.removeToken

        # Check for secured states on state change
        $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
            if !$rootScope.user and toState.secured
                e.preventDefault()
                return $state.go 'login', oldState: toState
            else if toState.redirect
                redir = toState.redirect
                if !redir then return
                e.preventDefault()
                if redir.indexOf('.') == 0
                    $state.go fromState.name + toState.redirect, null, location: "replace"
                else
                    $state.go redir, null, location: "replace"
]
