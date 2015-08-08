App.controller 'panelCtrl', [
    '$rootScope'
    '$scope'
    'Party'
    ($rootScope, $scope, Party) ->
        $scope.totalDue = 0
        $scope.totalOwe = 0

        $scope.parties = Party.query user: $rootScope.user.id, ->
            for party in $scope.parties
                party.due = 0
                party.owe = 0
                party.userExpenses = []
                party.indebted = []
                # Count users per expense
                party.cntExpenses = {}
                for participant in party.participants
                    # Get current user expenses
                    if participant.User == $rootScope.user.id
                        party.userExpenses = participant.expenses || []
                    for expense in participant.expenses
                        if !party.cntExpenses[expense] then party.cntExpenses[expense] = []
                        party.cntExpenses[expense].push participant.User || participant.name
                for pExpense in party.expenses
                    if pExpense.to == $rootScope.user.id
                        party.owe += pExpense.cost
                        $scope.totalOwe += pExpense.cost
                        if $rootScope.user.id in party.cntExpenses[pExpense.name]
                            party.owe -= pExpense.cost / party.cntExpenses[pExpense.name].length
                            $scope.totalOwe -= pExpense.cost / party.cntExpenses[pExpense.name].length
                # Check due
                for pExpense in party.expenses
                    for uExpense in party.userExpenses
                        if  pExpense.name == uExpense and pExpense.to != $rootScope.user.id
                            due = pExpense.cost / party.cntExpenses[pExpense.name].length
                            party.due += due
                            $scope.totalDue += due
]