commonServices = angular.module('common.services', ['ngResource'])

commonServices.factory 'Alerts', ['$resource', ($resource) ->
  alert = {
    alerts: {
        success: {}
        info: {}
        warning: {}
        danger: {}
      }
    addAlert: (key, message, type) ->
      if alert.alerts[type][key] is undefined
        alert.alerts[type][key] = []
      alert.alerts[type][key].push message
    clearAlerts: (key, type) ->
      delete alert.alerts[type][key]
    hasAlerts: (key, type) ->
      alert.alerts[type][key] isnt undefined
    clearDOMAlerts: (key) ->
      parent = $("alerts[key='#{key}']")
      for type in ['success', 'info', 'warning', 'danger']
        parent.find(".#{type}").empty()
    clearAllDOMAlerts: ->
      parent = $("alerts")
      for type in ['success', 'info', 'warning', 'danger']
        parent.find(".#{type}").empty()
    processResourceAlerts: (errors) ->
      for key, messages of errors
        for message in messages
          alert.addAlert(key, "#{key} #{message}", 'danger')
  }
]
