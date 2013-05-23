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
    {text: 'Decks', href: '/decks', regex: '/decks.*', subMenu: [
      {href: '/decks', state: 'decks.index', text: 'Recent'}
      {href: '/decks/edit/', state: 'decks.edit', text: 'New'}
      {href: '/decks/mine', state: 'decks.mine', text: 'Mine'}
    ]}
  ]
  $scope.userLinks = [
    {href: '/register', regex: '/register.*', state: 'account.register', text: 'Register', whenLogged: false}
    {href: '/login', regex: '/login.*', state: 'account.login', text: 'Login', whenLogged: false}
    {href: '/account', regex: '/account.*', state: 'account.viewAccount', text: 'Account', whenLogged: true}
    {href: '/logout', regex: '/logout.*', text: 'Logout', whenLogged: true}
  ]

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
  $scope.cardTypes = ['Creature', 'Land', 'Artifact', 'Enchantment', 'Instant', 'Sorcery']

  if $stateParams.deckId
    CardList.get {cardlistId: $stateParams.deckId, populate: {path: 'cards.card'}}, (response) ->
      $scope.deck = new CardList response
      $scope.viewedCard = $scope.deck.cards[0]
      $scope.deck.type ?= 'deck'
  else
    $scope.deck = new CardList()
    $scope.deck.type ?= 'deck'

  $scope.submit = ->
    $scope.savedDeck = angular.copy $scope.deck
    for card, i in $scope.savedDeck.cards
       $scope.savedDeck.cards[i].card = card.card._id if card.card._id?
    $scope.savedDeck.$save (response) ->
      $scope.$emit 'message', 'success', 'Your deck has been saved!'
      CardList.get {cardlistId: response._id, populate: {path:'cards.card'}}, (response) ->
        $scope.deck = new CardList(response)
    , (response) ->
      $scope.$emit 'message', 'error', "Something went wrong: #{message ? response.data.err ? response.data}"

  $scope.info = ->
    console.log $scope.deck

  $scope.setViewedCard = (card) ->
    $scope.viewedCard = card

  $scope.removeCard = (card) ->
    $scope.deck.cards.splice($scope.deck.cards.indexOf(card), 1)

  $scope.decrementCardCount = (card) ->
    if --card.quantity is 0
      $scope.removeCard card

  $scope.incrementCardCount = (card) ->
    card.quantity++

  $scope.addCardByName = (cardName) ->
    Card.query {where: {name: "^#{cardName}$"}}, (response) ->
      if response.length
        $scope.newCard = ''
        $scope.deck.cards.push {card: response[response.length-1], quantity: 1}
      else
        $scope.$emit 'message','error',"Card '#{cardName}' not found"

  $scope.findCardByName = (cardName) ->
    Card.query {where: {name: cardName}, fields: 'name _id'}, (response) ->
      cards = []
      for card in response
        cards.push "#{card.name}" unless card.name in cards
      $scope.possibleCards = cards

  $scope.filterType = (type) ->
    console.log type
    console.log arguments
    return (elem) ->
      console.log elem
      console.log type
      if elem.card?.types? and type in elem.card.types
        return true
      return false
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
