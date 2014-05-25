fbmApp = angular.module('fbmApp')

fbmApp.controller 'IndexCtrl', ['$scope', '$location', 'Auth', 'Alerts', 'currentUser', ($scope, $location, Auth, Alerts, currentUser) ->
  $scope.login = ->
    Alerts.clearAllDOMAlerts()
    Auth.login($scope.email, $scope.password).then(
      (user) ->
        if Auth.redirect is null
          $location.path("/users/view/#{user.id}")
        else
          loc = Auth.redirect
          Auth.redirect = null
          $location.path(loc)
    ,
      (data) ->
        if data.warning isnt undefined
          Alerts.addAlert('index', data.warning, 'warning')
          Alerts.addAlert('index', "Need to resend the confirmation email? <span ng-click=\"action()\" class=\"alert-link\">Click here</span>.", 'warning')
        else
          Alerts.addAlert('index', data.danger, 'danger')
    )

  $scope.resendActivation = ->
    Alerts.clearAllDOMAlerts()          
    Auth.resendActivation($scope.email).then(
      (user) ->
        Alerts.addAlert('index', "Confirmation email resent to #{user.email}.", 'info')
    ,
      (data) ->
        Alerts.addAlert('index', data.danger, 'danger')
    )

  $scope.currentUser = currentUser

  $scope.logout = ->
    Alerts.clearAllDOMAlerts()          
    $scope.currentUser = null
    Auth.logout().then(
      (data) ->
        Alerts.addAlert('index', data.info, 'info')
    ,
      (error) ->
        Alerts.addAlert('index', error.danger, 'danger')
    )

  $scope.sendResetPassword = ->
    Alerts.clearAllDOMAlerts()          
    if $scope.email == ""
      Alerts.addAlert('index', 'Please fill in your email then click "Forgot your password?" again.', 'info')
    else
    Auth.sendResetPassword($scope.email).then(
      (user) ->
        Alerts.addAlert('index', "Password reset instructions sent to #{user.email}.", 'info')
    ,
      (data) ->
        Alerts.addAlert('index', data.danger, 'danger')
    )
]
