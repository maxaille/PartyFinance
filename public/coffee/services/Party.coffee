angular.module 'PartyFinance'
.factory 'Party', [
    '$resource'
    'API'
    ($resource, API) ->
        $resource API + '/api/parties/:id/:arg', id: '@id', arg: '@arg'
]