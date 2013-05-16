module = angular.module 'MtGApps.directives', []
module.directive "mtgEqual", [->
  require: "ngModel"
  link: (scope, elm, attr, ctrl) ->
    pwdWidget = elm.inheritedData("$formController")[attr.mtgEqual]
    ctrl.$parsers.push (value) ->
      if value is pwdWidget.$viewValue
        ctrl.$setValidity "MATCH", true
        return value
      ctrl.$setValidity "MATCH", false

    pwdWidget.$parsers.push (value) ->
      ctrl.$setValidity "MATCH", value is ctrl.$viewValue
      value

]