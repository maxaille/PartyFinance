App.controller 'registerCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$state'
    'API'
    ($rootScope, $scope, $http, $state, API) ->
        $scope.validate = ->
            if $scope.password != $scope.passwordRepeat then return
            $http.post API + '/api/users', username: $scope.username, password: $scope.password, email: $scope.email
            .success (data) ->
                $state.go 'login', user: username: $scope.username, password: $scope.password
                console.log data
            .error (data) ->
                console.log data
]