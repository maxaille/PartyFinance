App.controller 'loginCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$state'
    '$stateParams'
    '$timeout'
    'API'
    ($rootScope, $scope, $http, $state, $stateParams, $timeout, API) ->
        sendLogin = (user) ->
            $http.post API + '/login', user
            .success (data) ->
                $rootScope.$broadcast 'user:loggedin', user: data.user, exp: data.exp*1000

        $scope.validate = (form) ->
            # Use 'form' for checking fields
            sendLogin username: $scope.username, password: $scope.password
            .success (data) ->
                $state.go if $stateParams.oldState then $stateParams.oldState.name else 'start'
            .error (data) ->
                console.log data

        if $stateParams.user
            sendLogin $stateParams.user
            .success ->
                $state.go 'start'
            .error ->
                console.log 'nok'
]