sessionsServices = angular.module('sessions.services', ['ngResource'])

sessionsServices.factory 'Auth', ['$http', '$q', '$location', '$window', 'Alerts', ($http, $q, $location, $window, Alerts) ->
  auth = {
    login: (email, password) ->
      delay = $q.defer()
      $http.post('/api/login', {email: email, password: password}).success(
        (data, status, headers, config) ->
          $window.sessionStorage.token = data.api_key
          delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delete $window.sessionStorage.token
          delay.reject(data)
      )
      return delay.promise
    logout: ->
      delay = $q.defer()
      $http.delete('/api/logout').success(
        (data, status, headers, config) ->
          delete $window.sessionStorage.token
          delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delay.reject(data)
      )
      return delay.promise
    currentUser: ->
      delay = $q.defer()
      $http.get('/api/users/me').success(
        (data, status, headers, config) ->
          if data == 'null'
            delay.resolve(null)
          else
            delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delay.reject("Unable to fetch current user")      
      )
      return delay.promise
    permission: (user, admin) ->
      if user is null
        Alerts.addAlert('index', 'You must be logged in to access that page.', 'danger')
        auth.redirect = $location.url()
        $location.path('/')
      else if user.admin is false and admin is true
        Alerts.addAlert('index', 'You must be an admin to access that page.', 'danger')
        auth.redirect = $location.url()
        $location.path('/')              
    # where to redirect after logging in following an authorization failure
    redirect: null
    activate: (token) ->
      delay = $q.defer()
      $http.get("/api/activate/#{token}").success(
        (data, status, headers, config) ->
          delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delay.reject(data)
      )
      return delay.promise
    resendActivation: (email) ->
      delay = $q.defer()
      $http.post("/api/activate/resend", {email: email}).success(
        (data, status, headers, config) ->
          delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delay.reject(data)
      )
      return delay.promise
    sendResetPassword: (email) ->
      delay = $q.defer()
      $http.post("/api/reset/send", {email: email}).success(
        (data, status, headers, config) ->
          delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delay.reject(data)
      )
      return delay.promise
    resetPassword: (token, password, passwordConfirmation) ->
      delay = $q.defer()
      $http.post("/api/reset", {token: token, password: password, password_confirmation: passwordConfirmation}).success(
        (data, status, headers, config) ->
          delay.resolve(data)
      ).error(
        (data, status, headers, config) ->
          delay.reject(data)
      )
      return delay.promise
  }
  return auth
]
