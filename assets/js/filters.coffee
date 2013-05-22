module = angular.module 'MtGApps.filters', []

module.filter 'isType', () ->
  (input, cardType) ->
    out = []
    if input?
      for card in input
        if card.card.types? and cardType in card.card.types
          out.push card
    return out