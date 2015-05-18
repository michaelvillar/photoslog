View = require('view')

class SVGView extends View
  className: 'svg'
  tag: 'svg'
  xmlns: "http://www.w3.org/2000/svg"

  constructor: ->
    super

    if @tag == 'svg'
      @el.setAttributeNS(null, 'version', "1.1")
      # @el.setAttributeNS(null, 'viewBox', "0 0 100% 100%")
      @el.setAttributeNS(null, 'width', "100%")
      @el.setAttributeNS(null, 'height', "100%")
      @el.setAttributeNS(null, 'focusable', 'false')

  createRect: (frame, options={}) =>
    rect = new Rect
    rect.setFrame(frame)
    rect.setFill(options.fill) if options.fill?
    rect.setClipRule(options.clipRule) if options.clipRule?
    rect.setFillRule(options.fillRule) if options.fillRule?
    rect.el.classList.add(options.className) if options.className?
    @addSubview(rect)
    rect

  createMask: =>
    mask = new Mask
    @addSubview(mask)
    mask

  createImage: =>
    image = new Image
    @addSubview(image)
    image

  setMask: (mask) =>
    @el.setAttributeNS(null, 'mask', 'url(#' + mask.name() + ')')

  setClipRule: (rule) =>
    @el.setAttributeNS(null, 'clip-rule', rule)

  setFillRule: (rule) =>
    @el.setAttributeNS(null, 'fill-rule', rule)

maskPathCount = 0
class Mask extends SVGView
  tag: 'mask'
  className: ''

  constructor: ->
    super

    @id = maskPathCount
    maskPathCount++
    @el.setAttributeNS(null, 'id', @name())

  name: =>
    "mask#{@id}"

class Rect extends SVGView
  tag: 'rect'
  className: ''

  setFrame: (@frame) =>
    @el.setAttributeNS(null, 'x', @frame.x)
    @el.setAttributeNS(null, 'y', @frame.y)
    @el.setAttributeNS(null, 'width', @frame.width)
    @el.setAttributeNS(null, 'height', @frame.height)

  setFill: (fill) =>
    @el.setAttributeNS(null, 'style', "fill:"+fill)

class Image extends Rect
  tag: 'image'
  className: ''

  setURL: (href) =>
    @el.setAttributeNS("http://www.w3.org/1999/xlink", 'href', href)

module.exports = SVGView
