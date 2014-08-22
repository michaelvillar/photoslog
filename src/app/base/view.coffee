EventDispatcher = require('eventDispatcher')

clone = (obj) ->
  JSON.parse(JSON.stringify(obj))

getOffset = (el, property) ->
  value = 0
  while el?
    value += el[property]
    el = el.offsetParent
  value

convertCoordinateToScreen = (coordinates) ->
  scroll = getWindowScroll()
  obj = clone(coordinates)
  obj.x = coordinates.x - scroll.x
  obj.y = coordinates.y - scroll.y
  obj

getWindowScroll = do ->
  scroll = {}
  gen = ->
    scroll =
      x: window.scrollX
      y: window.scrollY
  gen()
  window.addEventListener('scroll', gen)
  -> scroll

getWindowSize = do ->
  size = {}
  gen = ->
    size =
      width: window.innerWidth
      height: window.innerHeight
  gen()
  window.addEventListener('resize', gen)
  -> size

getRectsIntersection = (a, b) ->
  x = Math.max(a.x, b.x);
  num1 = Math.min(a.x + a.width, b.x + b.width);
  y = Math.max(a.y, b.y);
  num2 = Math.min(a.y + a.height, b.y + b.height);
  if num1 >= x and num2 >= y
    return { x: x, y: y, width: num1 - x, height: num2 - y }
  null

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

  text: (text) =>
    @el.innerHTML = text

  height: =>
    @el.clientHeight

  width: =>
    @el.clientWidth

  x: =>
    getOffset(@el, 'offsetLeft')

  y: =>
    getOffset(@el, 'offsetTop')

  position: =>
    x: @x()
    y: @y()

  size: =>
    width: @width()
    height: @height()

  frame: =>
    x: @x()
    y: @y()
    width: @width()
    height: @height()

  visibleBounds: =>
    viewFrameInScreen = convertCoordinateToScreen(@frame())
    windowFrame = getWindowSize()
    windowFrame.x = 0
    windowFrame.y = 0
    getRectsIntersection(viewFrameInScreen, windowFrame)

module.exports = View
