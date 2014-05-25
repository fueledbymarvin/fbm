usersServices = angular.module('users.services', ['ngResource'])

usersServices.factory 'User', ['$resource', ($resource) ->
  $resource("/api/users/:id", { id: "@id" },
      'create':  { method: 'POST' },
      'index':   { method: 'GET', isArray: true }
      'show':    { method: 'GET', isArray: false }
      'update':  { method: 'PUT' }
      'destroy': { method: 'DELETE' }
  )
]

usersServices.factory "UsersListLoader", ["User", "$q", (User, $q) ->
  return ->
    delay = $q.defer()
    User.query(
      (users) ->
        delay.resolve(users)
    ,
      (error) ->
        delay.reject(error)
    )
    return delay.promise
]

usersServices.factory "UsersLoader", ["User", "$route", "$q", (User, $route, $q) ->
  return ->
    delay = $q.defer()
    User.get(
      { id: $route.current.params.userId }
    ,
      (user) ->
        delay.resolve(user)
    ,
      (error) ->
        delay.reject(error)
    )
    return delay.promise
]
