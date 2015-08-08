App.controller 'partyCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    'fgDelegate'
    'Party'
    ($rootScope, $scope, $state, fgDelegate, Party) ->
        refreshData = ->
            $scope.parties.$promise.then ->
                party = do -> return party for party in $scope.parties when party.id == $state.params.id
                if !party
                    return $state.go 'panel.overview'
                $scope.party = Party.get id: party.id, ->
                    console.log $scope.party
                    $scope.party.due = party.due
                    $scope.party.owe = party.owe
#                    $scope.userExpenses = party.userExpenses
#                    $scope.cntExpenses = party.cntExpenses
#                    $scope.party.creditors = []
                    $scope.party.indebted = []
                    indebted = []

                    for expense in $scope.party.expenses when expense.to.id == $rootScope.user.id
                        for participant in expense.participants when participant.user.id != $rootScope.user.id
                            i = indebted.indexOf participant.user.id
                            if i > -1
                                $scope.party.indebted[i].due += expense.cost / expense.participants.length
                            else
                                i = ($scope.party.indebted.push participant: participant, due: expense.cost / expense.participants.length - participant.paid, dueExpenses: []) - 1
                                indebted.push participant.user.id
                            $scope.party.indebted[i].dueExpenses.push expense

#                    creditors = []

#                    # Search all creditors
#                    for e in $scope.userExpenses
#                        exp = do -> return exp for exp in $scope.party.expenses when exp.name == e
#                        if exp.to.id != $rootScope.user.id
#                            creditor = do -> return p.User.username for p in $scope.party.participants when p.User.id == exp.to.id
#
#                            i = creditors.indexOf creditor
#                            if i > -1
#                                $scope.party.creditors[i].due += exp.cost / $scope.cntExpenses[e].length
#                            else
#                                i = ($scope.party.creditors.push name: creditor, due: exp.cost / $scope.cntExpenses[e].length, dueExpenses: []) - 1
#                                creditors.push creditor
#                            $scope.party.creditors[i].dueExpenses.push exp
#                    # Search all who owe you money
#                    for e in $scope.party.expenses when e.to.id == $scope.user.id
#                        for id in $scope.cntExpenses[e.name]
#                            if id == $rootScope.user.id then continue
#                            name = (do -> return u.User.username for u in $scope.party.participants when u.User.id == id) or id
#
#                            i = indebted.indexOf name
#                            if i > -1
#                                $scope.party.indebted[i].due += e.cost/$scope.cntExpenses[e.name].length
#                            else
#                                i = ($scope.party.indebted.push name: name, due: e.cost/$scope.cntExpenses[e.name].length, dueExpenses: []) - 1
#                                indebted.push name
#                            $scope.party.indebted[i].dueExpenses.push e

                    partyGrid = fgDelegate.getFlow('partyGrid')
                    setTimeout (-> partyGrid.refill true), 0
        refreshData()

        $scope.portlet_expenses =
            actions: []
            save: ->
                data =
                    id: $scope.party.id
                for expense in $scope.party.expenses
                    if expense.name == "" or !expense.cost or expense.cost == 0 then return
                    expense.to = expense.to.id
                    if !data.expenses then data.expenses = []
                    data.expenses.push expense
                if $scope.portlet_expenses.actions.length > 0
                    console.log $scope.party.participants
                    for action in $scope.portlet_expenses.actions
                        if action.add
                            user = do -> participant for participant in $scope.party.participants when participant.User.username == action.add
                            if !user then return
                            console.log expense.name
                Party.update id: $scope.party.id, expenses: $scope.party.expenses, (data) ->
                    $scope.portlet_expenses.edit = false
                    refreshData()
                , (data) ->
                    console.log data


]