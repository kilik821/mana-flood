module = angular.module 'MtGApps.services', ['ngResource']
module.factory 'User', ['$resource', ($resource) ->
  $resource 'api/users/:userId/:action', {userId: '@id'},
    $login: {method: 'POST', params: {action: 'login', userId: 'all'}}
    login: {method: 'POST', params: {action: 'login', userId: 'all'}}
    logout: {method: 'GET', params: {action: 'logout', userId: 'all'}}
    current: {method: 'GET', params: {action: 'currentUser', userId: 'all'}}
    online: {method: 'GET', params: {action: 'online', userId: 'all'}, isArray: true}
]
module.factory 'CardList', ['$resource', ($resource) ->
  $resource 'api/cardlists/:cardlistId/:action', {cardlistId: '@id'}, {}
]