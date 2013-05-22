module = angular.module 'MtGApps', ['$strap','ui.compat','MtGApps.services', 'MtGApps.directives', 'MtGApps.controllers', 'MtGApps.filters']
module.config ['$routeProvider', '$locationProvider', '$stateProvider', ($routeProvider, $locationProvider, $stateProvider)->
  $locationProvider.html5Mode true
  $stateProvider
    .state('decks', {templateUrl: 'partials/decks', abstract: true, url:'/decks'})
    .state('decks.index', {templateUrl: 'partials/decks/view', url: '', controller: 'DeckIndexCtrl'})
    .state('decks.edit', {templateUrl: 'partials/decks/create', url: '/edit/:deckId', controller: 'DeckEditCtrl'})
    .state('cards', {templateUrl: 'partials/cards', abstract: true})
    .state('cards.view', {templateUrl: 'partials/cards/view', url: '/cards', controller: 'CardCtrl'})
    .state('account', {templateUrl: 'partials/account', abstract: true, controller: 'AccountCtrl'})
    .state('account.viewAccount', {templateUrl: 'partials/account/view', url: '/account', controller: 'ViewAccountCtrl'})
    .state('account.register', {templateUrl: 'partials/account/register', url: '/register', controller: 'RegisterCtrl'})
    .state('account.login', {templateUrl: 'partials/account/login', url:'/login', controller: 'UserLoginCtrl'})
  $routeProvider
    .when('/', {templateUrl: 'partials/index', controller: 'IndexCtrl'})
    .when('/logout', {controller: 'UserLogoutCtrl'})
    .when(/.*/, {redirectTo: '/'})
]
