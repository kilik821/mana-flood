module = angular.module 'MtGApps', ['ui.compat','MtGApps.services', 'MtGApps.directives', 'MtGApps.controllers', 'MtGApps.filters']
module.config ['$routeProvider', '$locationProvider', '$stateProvider', ($routeProvider, $locationProvider, $stateProvider)->
  $locationProvider.html5Mode true
  $stateProvider
    .state('lists', {templateUrl: 'partials/cardlists', abstract: true, controller: 'CardListCtrl'})
    .state('lists.index', {templateUrl: 'partials/cardlists', url: '/decks', controller: 'CardListCtrl'})
    .state('account', {templateUrl: 'partials/account', abstract: true, controller: 'AccountCtrl'})
    .state('account.viewAccount', {templateUrl: 'partials/account/view', url: '/account', controller: 'ViewAccountCtrl'})
    .state('account.register', {templateUrl: 'partials/account/register', url: '/register', controller: 'RegisterCtrl'})
    .state('account.login', {templateUrl: 'partials/account/login', url:'/login', controller: 'UserLoginCtrl'})
  $routeProvider
    .when('/', {templateUrl: 'partials/index', controller: 'IndexCtrl'})
    .when('/logout', {controller: 'UserLogoutCtrl'})
    .when(/.*/, {redirectTo: '/'})
]
