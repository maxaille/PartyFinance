App.controller 'partyCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    'Party'
    ($rootScope, $scope, $state, Party) ->
        $scope.parties.$promise.then ->
            party = do -> return party for party in $scope.parties when party.id == $state.params.id
            if !party
                return $state.go 'panel.overview'
            $scope.party = Party.get id: party.id, ->
                $scope.party.due = party.due
                $scope.party.owe = party.owe
                $scope.userExpenses = party.userExpenses
                $scope.cntExpenses = party.cntExpenses
                $scope.party.creditors = []
                $scope.party.indebted = []
                creditors = []
                indebted = []

                # Search all creditors
                for e in $scope.userExpenses
                    exp = do -> return exp for exp in $scope.party.expenses when exp.name == e
                    if exp.to != $rootScope.user.id
                        creditor = do -> return p.User.username for p in $scope.party.participants when p.User.id == exp.to

                        i = creditors.indexOf creditor
                        if i > -1
                            $scope.party.creditors[i].due += exp.cost / $scope.cntExpenses[e].length
                        else
                            i = ($scope.party.creditors.push name: creditor, due: exp.cost / $scope.cntExpenses[e].length, dueExpenses: []) - 1
                            creditors.push creditor
                        $scope.party.creditors[i].dueExpenses.push exp
                # Search all who owe you money
                for e in $scope.party.expenses when e.to == $scope.user.id
                    for id in $scope.cntExpenses[e.name]
                        if id == $rootScope.user.id then continue
                        name = (do -> return u.User.username for u in $scope.party.participants when u.User.id == id) or id

                        i = indebted.indexOf name
                        if i > -1
                            $scope.party.indebted[i].due += e.cost/$scope.cntExpenses[e.name].length
                        else
                            i = ($scope.party.indebted.push name: name, due: e.cost/$scope.cntExpenses[e.name].length, dueExpenses: []) - 1
                            indebted.push name
                        $scope.party.indebted[i].dueExpenses.push e
                        console.log

        $scope.portlet_expenses = {}
        $scope.portlet_expenses.save = ->
            console.log "saving"

]