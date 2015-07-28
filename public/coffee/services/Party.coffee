angular.module 'PartyFinance'
.factory 'User', [
    '$resource'
    '$modal'
    ($resource) ->
        $resource '/api/parties/:id/:arg', id: '@id', arg: '@arg',
            'update': method: 'PUT'
]