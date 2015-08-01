App.controller 'panelCtrl', [
    '$rootScope'
    '$scope'
    'Party'
    ($rootScope, $scope, Party) ->
        $scope.totalDue = 0
        $scope.totalOwe = 0

        $scope.parties = Party.query user: $rootScope.user.id, ->
            for party in $scope.parties
                console.log "PARTY NAME: ", party.name
                party.due = 0
                party.owe = 0
                uExpenses = []
                # Count users per expense
                cntExpenses = {}
                for participant in party.participants
                    # Get current user expenses
                    if participant.User == $rootScope.user.id
                        uExpenses = participant.expenses || []
                    for expense in participant.expenses
                        if !cntExpenses[expense] then cntExpenses[expense] = []
                        cntExpenses[expense].push participant.User || participant.name
                for pExpense in party.expenses
                    if pExpense.to == $rootScope.user.id
                        party.owe = pExpense.cost
                        $scope.totalOwe += pExpense.cost
                        if $rootScope.user.id in cntExpenses[pExpense.name]
                            party.owe -= pExpense.cost / cntExpenses[pExpense.name].length
                            $scope.totalOwe -= pExpense.cost / cntExpenses[pExpense.name].length
                # Check due
                for pExpense in party.expenses
                    for uExpense in uExpenses
                        if  pExpense.name == uExpense and pExpense.to != $rootScope.user.id
                            due = pExpense.cost / cntExpenses[pExpense.name].length
                            party.due += due
                            $scope.totalDue += due
]