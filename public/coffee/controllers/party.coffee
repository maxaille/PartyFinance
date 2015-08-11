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
                    $scope.orgExpenses = angular.copy $scope.party.expenses
                    $scope.party.due = party.due
                    $scope.party.owe = party.owe
#                    $scope.userExpenses = party.userExpenses
#                    $scope.cntExpenses = party.cntExpenses
                    $scope.party.creditors = []
                    $scope.party.indebted = []
                    indebted = []
                    creditors = []

                    for expense in $scope.party.expenses
                        for participant in expense.participants

                            # Indebted
                            if expense.to.id == $rootScope.user.id and participant.user.id != $rootScope.user.id
                                i = indebted.indexOf participant.user.id
                                console.log expense.name, participant.user, indebted

                                if i > -1
                                    $scope.party.indebted[i].due += expense.cost / expense.participants.length
                                else
                                    i = ($scope.party.indebted.push participant: participant, due: expense.cost / expense.participants.length - participant.paid, dueExpenses: []) - 1
                                    indebted.push participant.user.id
                                $scope.party.indebted[i].dueExpenses.push expense







                            # Creditors
                            else if expense.to.id != $rootScope.user.id and participant.user.id == $rootScope.user.id
                                creditor = expense.to
                                i = creditors.indexOf creditor.id
                                if i > -1
                                    $scope.party.creditors[i].due += expense.cost / expense.participants.length - participant.paid
                                else
                                    i = ($scope.party.creditors.push creditor: creditor, due: expense.cost / expense.participants.length - participant.paid, dueExpenses: []) - 1
                                    creditors.push creditor.id
                                $scope.party.creditors[i].dueExpenses.push expense
                    partyGrid = fgDelegate.getFlow('partyGrid')
                    setTimeout (-> partyGrid.refill true), 0

        refreshData()

        $scope.notAdded = (expense) ->
            (item) ->
                !(do -> return value for value in expense.participants when value.user.id == item.id) and
                !(do -> return action for action in $scope.portlet_expenses.actions when action.add and action.add.id == item.id)


        $scope.portlet_expenses =
            actions: []
            addUser: (user, expense) ->
                if user and user.id and
                   !(do -> return true for participant in expense.participants when participant.user.id == user.id) and
                   !(do -> return true for action in $scope.portlet_expenses.actions when action.add and action.add.id == user.id)
                    $scope.portlet_expenses.actions.push add: user, expense: expense
                    return ''
                return user
            save: ->
                data =
                    id: $scope.party.id
                for expense in $scope.party.expenses
                    if expense.name == "" or !expense.cost or expense.cost == 0 then return
                    expense.to = expense.to.id
                    if !data.expenses then data.expenses = []
                    data.expenses.push expense
                if $scope.portlet_expenses.actions.length > 0
                    # Correctly reformat expenses
                    resExpenses = data.expenses
                    for expense in resExpenses
                        for participant in expense.participants
                            if participant.user.id
                                participant.user = participant.user.id

                        # Update each expense
                        for action in $scope.portlet_expenses.actions when action.expense.name == expense.name
                            if action.add
                                expense.participants.push paid: 0, user: action.add.id
                            else if action.remove
                                expense.participants.splice(participant, 1) for participant in expense.participants when participant.user == action.remove.id
                console.log data


                Party.update data, (data) ->
                    $scope.portlet_expenses.edit = false
                    $scope.portlet_expenses.actions = []
                    refreshData()
                , (data) ->
                    console.log data


]