fbmApp = angular.module('fbmApp')

fbmApp.controller 'UsersListCtrl', ['$scope', 'users', ($scope, users) ->
  $scope.users = users
]

fbmApp.controller 'UsersViewCtrl', ['$scope', '$location', 'user', 'Auth', 'Alerts', ($scope, $location, user, Auth, Alerts) ->
  $scope.user = user
]

fbmApp.controller 'UsersEditCtrl', ['$scope', '$location', 'user', 'Alerts', ($scope, $location, user, Alerts) ->
  $scope.user = user

  $scope.save = ->
    $scope.user.$update(
      (user) ->
        Alerts.addAlert('userView', 'Successfully updated profile.', 'success')
        $location.path("/users/view/" + user.id)
    ,
      (response) ->
        Alerts.processResourceAlerts(response.data)
    )

  $scope.delete = ->
    $scope.user.$delete(
      (data) ->
        Alerts.addAlert('index', 'Your account has been deleted.', 'warning')
        $location.path("/")
        delete $scope.user
    ,
      (error) ->
        Alerts.addAlert('index', error.danger, 'danger')
        $location.path("/")
    )
]

fbmApp.controller 'UsersNewCtrl', ['$scope', '$location', 'User', 'Alerts', ($scope, $location, User, Alerts) ->
  $scope.user = new User()

  Alerts.clearAllDOMAlerts()
  $scope.save = ->
    $scope.user.$save(
      (user) ->
        Alerts.addAlert('index', "Successfully registered! Please check your inbox to confirm your email address.", 'success')
        $location.path('/')
    , (response) ->
        for key, messages of response.data
          for message in messages
            Alerts.addAlert(key, "#{key} #{message}", 'danger')
    )
]

fbmApp.controller 'UsersActivateCtrl', ['$scope', '$location', '$routeParams', 'Auth', 'Alerts', ($scope, $location, $routeParams, Auth, Alerts) ->
  Auth.activate($routeParams.token).then(
    (user) ->
      Alerts.addAlert('index', "Congrats! Your account is now activated.", 'success')
      $location.path('/')
  ,
    (data) ->
      Alerts.addAlert('index', data.danger, 'danger')
  )
]

fbmApp.controller 'UsersResetCtrl', ['$scope', '$location', '$routeParams', 'Auth', 'Alerts', ($scope, $location, $routeParams, Auth, Alerts) ->
  $scope.resetPassword = ->
    Auth.resetPassword($routeParams.token, $scope.password, $scope.passwordConfirmation).then(
      (user) ->
        Alerts.addAlert('index', "Your password has been reset.", 'success')
        $location.path('/')
    ,
      (data) ->
        if data.danger isnt undefined
          Alerts.addAlert('index', data.danger, 'danger')
        else
          for key, messages of data
            for message in messages
              Alerts.addAlert(key, "#{key} #{message}", 'danger')              
    )
]
