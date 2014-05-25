fbmApp = angular.module('fbmApp', ['ngRoute', 'users.services', 'sessions.services', 'common.services', 'common.directives'])

fbmApp.config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $routeProvider.when('/'
    controller: 'IndexCtrl'
    templateUrl: '/assets/index.html'
    resolve:
      currentUser: ['Auth', (Auth) ->
        return Auth.currentUser()
      ]
  ).when('/users',
    controller: 'UsersListCtrl'
    resolve:
      users: ['UsersListLoader', (UsersListLoader) ->
        return UsersListLoader()
      ]
    templateUrl: '/assets/users/index.html'
  ).when('/users/view/:userId',
    controller: 'UsersViewCtrl'
    resolve:
      user: ['UsersLoader', (UsersLoader) ->
        return UsersLoader()
      ]
    templateUrl: '/assets/users/view.html'
  ).when('/users/edit/:userId',
    controller: 'UsersEditCtrl'
    resolve:
      user: ['UsersLoader', (UsersLoader) ->
        return UsersLoader()
      ]
    templateUrl: '/assets/users/edit.html'
  ).when('/users/new',
    controller: 'UsersNewCtrl'
    templateUrl: '/assets/users/new.html'
  ).when('/activate/:token',
    controller: 'UsersActivateCtrl'
    template: ''
  ).when('/reset/:token',
    controller: 'UsersResetCtrl'
    templateUrl: '/assets/users/reset.html'
  ).otherwise(
    redirectTo: '/'
  )
])

fbmApp.config(['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push('authInterceptor')

  $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'
  $httpProvider.defaults.headers.common['Accept'] = 'application/vnd.fbm.v1'

  authToken = $('meta[name="csrf-token"]').attr('content')
  $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = authToken
])

fbmApp.controller 'AppCtrl', ['$rootScope', '$location', 'Auth', 'Alerts', ($rootScope, $location, Auth, Alerts) ->
  $rootScope.$on('$routeChangeError', (event, current, previous, rejection) ->
    Auth.redirect = $location.url()
    # if rejection isnt undefined and rejection.data.danger isnt undefined
    #   Alerts.addAlert('index', rejection.data.danger, 'danger')
    # else
    Alerts.addAlert('index', 'Sorry, something went wrong.', 'warning')
    if $location.url() isnt '/'
      $location.path('/')
  )
]

fbmApp.factory 'authInterceptor', ['$window', ($window) ->
  return {
    request: (config) ->
      config.headers = config.headers || {}
      if $window.sessionStorage.token
        config.headers.Authorization = "Token token=\"#{$window.sessionStorage.token}\""
      return config
  }
]
