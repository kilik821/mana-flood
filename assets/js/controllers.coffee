module = angular.module 'MtGApps.controllers', []

module.controller 'AppCtrl', ['$scope', 'User', '$timeout', '$state', ($scope, User, $timeout, $state) ->
  $scope.state = $state

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
    {title: 'Decks', subMenu: [
      {url: '/decks', state: 'decks.index', title: 'Recent'}
      {url: '/decks/edit/', state: 'decks.edit', title: 'New'}
      {url: '/decks/mine', state: 'decks.mine', title: 'Mine'}
    ]}
  ]
  $scope.userLinks = [
    {url: '/register', state: 'account.register', title: 'Register', whenLogged: false}
    {url: '/login', state: 'account.login', title: 'Login', whenLogged: false}
    {url: '/account', state: 'account.viewAccount', title: 'Account', whenLogged: true}
    {url: '/logout', title: 'Logout', whenLogged: true}
  ]
  links = $scope.mainLinks.concat($scope.userLinks)

  setSelected = (url) ->
    setSelectedRecur url, links

  setSelectedRecur = (url, links) ->
    return unless links?
    selected = null
    for link in links
      link.selected = false
      if link.url? and url.indexOf(link.url) >= 0
        selected = link
      result = setSelectedRecur url, link.subMenu
      if result? then link.selected = true
      selected = result ? selected
    if selected? then selected.selected = true
    return selected

  $rootScope.$on '$stateChangeSuccess', (event, current, previous) ->
    setSelected $location.path()
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

module.controller 'UserLogoutCtrl', ['$state', '$scope', ($state, $scope)->
  do $scope.logout
  $state.transitionTo 'account.login'
]

module.controller 'IndexCtrl', ['$scope', ($scope) ->

]

module.controller 'DeckIndexCtrl', ['$scope', 'CardList', ($scope, CardList) ->

]

module.controller 'DeckEditCtrl', ['$scope', 'CardList', '$stateParams', 'Card', ($scope, CardList, $stateParams, Card) ->
  $scope.deck = if $stateParams.deckId then CardList.get({cardlistId: $stateParams.deckId}) else new CardList()

  $scope.submit = ->
    $scope.deck.$save (response) ->
      $scope.$emit 'message', 'success', 'Your deck has been saved!'
      console.log response
      $scope.deck = new CardList(response)
    , (response) ->
      $scope.$emit 'message', 'error', "Something went wrong: #{message ? response.data.err ? response.data}"

  $scope.info = ->
    console.log $scope.deck

  $scope.removeCard = (card) ->
    $scope.deck.cards.splice($scope.deck.cards.indexOf(card), 1)

  $scope.addCardByName = (cardName) ->
    Card.query {where: {name: "^#{cardName}$"}, fields: 'name _id'}, (response) ->
      console.log response[response.length-1]
      $scope.deck.cards.push response[response.length-1]

  $scope.findCardByName = (cardName, callback) ->
    Card.query {where: {name: cardName}, fields: 'name _id'}, (response) ->
      cards = []
      for card in response
        cards.push "#{card.name}" unless card.name in cards
      $scope.possibleCards = cards
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
      $scope.$emit 'message', 'error', "Something went wrong: #{message ? response.data.err ? response.data}"
]

module.controller 'AccountCtrl', ['$scope', '$state', ($scope, $state) ->

]
module.controller 'ViewAccountCtrl', ['$scope', ($scope) ->

]
