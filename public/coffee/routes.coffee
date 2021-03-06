App.config [
    '$stateProvider'
    '$urlRouterProvider'
    ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider.otherwise '/'

        $stateProvider
        .state 'start',
            url: '/'
            title: 'start'
            controller: 'startCtrl'
            templateUrl: '/partials/start.html'

        .state 'login',
            url: '/login'
            controller: 'loginCtrl'
            title: 'login'
            templateUrl: '/partials/login.html'
            params: user: null, oldState: null

        .state 'register',
            url: '/register'
            controller: 'registerCtrl'
            title: 'register'
            templateUrl: '/partials/register.html'

        .state 'panel',
            url: '/panel'
            controller: 'panelCtrl'
            secured: true
            template: "<ui-view class='fade-in-up'/>"
            redirect: 'panel.overview'

        .state 'panel.overview',
            url: '/overview'
            title: 'Panel'
            templateUrl: '/partials/panel.html'
            secured: true

        .state 'panel.party',
            url: '/:id'
            controller: 'partyCtrl'
            title: 'Party'
            templateUrl: '/partials/party.html'
            secured: true

]