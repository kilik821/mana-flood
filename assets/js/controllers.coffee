module = angular.module 'MtGApps.controllers', []

module.controller 'AppCtrl', ['$scope', 'User', '$timeout', ($scope, User, $timeout) ->
  $scope.messages = []

  $scope.loggedUser = User.current (user) ->
    $scope.userIsLoggedIn = user.username?
  $scope.userIsLoggedIn = false;

  $scope.$on 'userLogin', (event, user) ->
    $scope.loggedUser = user
    $scope.userIsLoggedIn = user? and not not user

  userLogout = () ->
    $scope.loggedUser = null
    $scope.userIsLoggedIn = false

  $scope.$on 'userLogout', userLogout

  pushMessage = (type, message) ->
    $scope.messages.push {message: message, type: type}

  $scope.$on 'message', (event, type, message) ->
    pushMessage type, message

  $scope.delay = (cb, args..., duration) ->
    $timeout(()->
      cb.apply $scope, args
    , duration)

  $scope.removeMessage = (message) ->
    $scope.messages.splice($scope.messages.indexOf(message), 1)

  $scope.logout = ->
    if $scope.userIsLoggedIn
      User.logout()
      do userLogout
      pushMessage 'success', 'You have logged out.'
]

module.controller 'NavCtrl', ['$rootScope', '$scope', '$location', ($rootScope, $scope, $location) ->
  $scope.mainLinks = [
    {url: '/', title: 'Home'}
    {url: '/decks', title: 'Decks'}
  ]
  $scope.userLinks = [
    {url: '/register', title: 'Register', whenLogged: false}
    {url: '/login', title: 'Login', whenLogged: false}
    {url: '/account', title: 'Account', whenLogged: true}
    {url: '/logout', title: 'Logout', whenLogged: true}
  ]
  links = $scope.mainLinks.concat($scope.userLinks)
  setSelected = (url) ->
    parts = url.split('/')
    for part,i in parts by -1
      temp = parts.slice(0,i+1).join('/')
      for link in links
        if link.url is temp
          return $scope.selected = link
    $scope.selected = $scope.mainLinks[0]

  url = $location.path()
  setSelected url

  $rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
    setSelected $location.path()

  $scope.select = (item) ->
    $scope.selected = item
]

module.controller 'UserLoginCtrl', ['$scope', 'User', '$window', ($scope, User, $window)->
  $scope.login = ->
    loggedUser = User.login({username: $scope.loggingIn.username, password: $scope.loggingIn.password, userId: 'all'}, ()->
      $scope.$emit 'userLogin', loggedUser
      $scope.$emit 'message', 'success', "Welcome back #{loggedUser.username}!"
      $window.history.back()
    , (response) ->
      $scope.$emit 'message', 'error', response.data
    )
]

module.controller 'UserLogoutCtrl', ['$location', '$scope', ($location, $scope)->
  do $scope.logout
  $location.url '/'
]

module.controller 'IndexCtrl', ['$scope', ($scope) ->

]

module.controller 'CardListCtrl', ['$scope', 'CardList', '$route', ($scope, CardList, $route) ->

]

module.controller 'RegisterCtrl', ['$scope', 'User', '$location', ($scope, User, $location) ->
  $scope.registering = new User()
  $scope.register = () ->
    $scope.registering.$save () ->
      $scope.$emit 'message', 'success', 'You have successfully registered! You may now log in.'
      $location.url '/login'
    , (response) ->
      if response.data.code?
        switch response.data.code
          when 11000
            message = 'A user already exists with that email address'
      $scope.$emit 'message', 'error', 'Something went wrong: ' + message ? response.data.err ? response.data
]

module.controller 'AccountCtrl', ['$scope', '$state', ($scope, $state) ->

]
module.controller 'ViewAccountCtrl', ['$scope', ($scope) ->

]
