Module = require('module')

class EventDispatcher extends Module
  constructor: ->
    @eventCallbacks = {}

  on: (eventName, callback) =>
    @eventCallbacks[eventName] ||= []
    @eventCallbacks[eventName].push callback

  off: (eventName = null, callback = null) =>
    if !eventName
      @eventCallbacks = {}
    else if !callback
      @eventCallbacks[eventName] = []
    else
      @eventCallbacks[eventName] = @eventCallbacks[eventName].map (cb) ->
        cb if cb != callback

  trigger: (eventName, args...) =>
    tracker.trace.trigger eventName, args
    callbacks = @eventCallbacks[eventName]
    return unless callbacks?
    callbacks = callbacks.slice()
    for callback in callbacks
      callback(args...)

  triggerToSubviews: (eventName, args...) =>
    @trigger.apply(@, arguments)
    if @subviews?
      for subview in @subviews
        subview.triggerToSubviews.apply(subview, arguments)

  propagateEvent: (event, source) ->
    source.on(event, (args...) =>
      @trigger(event, args...)
      )

module.exports = EventDispatcher
