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
            title: 'Panel'
            templateUrl: '/partials/panel.html'
            secured: true
]