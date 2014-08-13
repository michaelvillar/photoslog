EventDispatcher = require('eventDispatcher')

class View extends EventDispatcher
  tag: 'div'

  constructor: (@options = {}) ->
    super
    @el = @el or @options.el or document.createElement(@options['tag'] || @tag)

    className = @className || @options.className
    @el.classList.add(className) if className?

    @subviews = []

    @render?()
    @bindEvents?()
    @layout?()

  addSubview: (subview) =>
    @el.appendChild(subview.el)
    @subviews.push(subview)

  addSubviews: (subviews = []) =>
    for subview in subviews
      @addSubview(subview)

module.exports = View
