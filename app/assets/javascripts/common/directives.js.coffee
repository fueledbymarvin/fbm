commonDirectives = angular.module('common.directives', [])

commonDirectives.directive 'alerts', ['Alerts', '$compile', (Alerts, $compile) ->
  return {
    restrict: 'E'
    scope:
      key: '@'
      action: '&'
    templateUrl: 'assets/common/alerts.html'
    link: (scope, element, attrs) ->
      scope.success = Alerts.alerts.success
      scope.info = Alerts.alerts.info
      scope.warning = Alerts.alerts.warning
      scope.danger = Alerts.alerts.danger

      renderAlerts = (messages, type) ->
        if messages isnt undefined
          wrapper = element.find(".#{type}")
          wrapper.empty()
          for message in messages
            wrapper.append("<div class=\"alert alert-#{type}\">#{message}</div>")
          $compile(angular.element(wrapper))(scope)
        Alerts.clearAlerts(scope.key, type)

      scope.$watchCollection('success', (messages) ->
        renderAlerts(messages[scope.key], 'success')
      )
      scope.$watchCollection('info', (messages) ->
        renderAlerts(messages[scope.key], 'info')
      )
      scope.$watchCollection('warning', (messages) ->
        renderAlerts(messages[scope.key], 'warning')
      )
      scope.$watchCollection('danger', (messages) ->
        renderAlerts(messages[scope.key], 'danger')
      )
  }
]

commonDirectives.directive 'textConfirm', ['Alerts', '$compile', (Alerts, $compile) ->
  return {
    restrict: 'E'
    scope:
      action: '&'
      instructions: '@'
      message: '@'
      target: '@'
    templateUrl: 'assets/common/confirm.html'
    link: (scope, element, attrs) ->
      scope.clicked = false
      scope.input = ""
      scope.activate = ->
        scope.clicked = true
      scope.$watch('input', (input) ->
        scope.check = input != scope.target
      )
  }
]

commonDirectives.directive 'navbar', ['$location', 'Auth', 'Alerts', ($location, Auth, Alerts) ->
  return {
    restrict: 'E'
    scope:
      user: '='
      active: '@'
    templateUrl: 'assets/common/navbar.html'
    link: (scope, element, attrs) ->
      scope.logout = ->
        Auth.logout().then(
          (data) ->
            Alerts.addAlert('index', data.info, 'info')
            $location.path('/')
        ,
          (error) ->
            Alerts.addAlert('index', error.danger, 'danger')
            $location.path('/')
        )
  }
]
