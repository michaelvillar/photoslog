View = require('view')
scroll = require('scroll')

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
pixelRatio = window.devicePixelRatio ? 1

multiply = (obj, value) ->
  newObj = {}
  for k, v of obj
    newObj[k] = v * value
  newObj

getWindowSize = do ->
  size = {}
  gen = ->
    size =
      width: window.innerWidth
      height: window.innerHeight
  gen()
  window.addEventListener('resize', gen)
  -> size

roundf = (v, decimal) ->
  d = Math.pow(10, decimal)
  return Math.round(v * d) / d

class TimelineView extends View
  className: 'timelineView'

  constructor: ->
    super

    @translateY = 0
    @canvas = new View(tag: 'canvas', className: 'curvedLinesCanvas')
    @ctx = @canvas.el.getContext("2d")
    @addSubview(@canvas)

    @verticalLineView = new View(tag: 'span', className: 'verticalLineView')
    @addSubview(@verticalLineView)

    @containerView = new View(className: 'containerView')
    @addSubview(@containerView)

    @selectedGroup = null

    window.addEventListener('resize', @onResize)
    window.addEventListener('load', =>
      @updateCanvasSize()
      @center()
      @redraw()
    )
    scroll.on('change', @onScroll)

  setVisibleGroups: (groups) =>
    groups.sort (a, b) ->
      a.rect.y > b.rect.y
    @visibleGroups = groups

    selectedGroup = null
    maxPortion = 0
    maxGroup = null
    for group in groups
      if group.portion > 0.66
        selectedGroup = group.group
        break

      if group.portion > maxPortion
        maxPortion = group.portion
        maxGroup = group.group

    selectedGroup = maxGroup if !selectedGroup

    if @selectedGroup != selectedGroup
      @setSelectedGroup(selectedGroup)
      @trigger('selectedGroupDidChange', selectedGroup)

    @redraw()

  setSelectedGroup: (group) =>
    if @selectedGroup != group
      @selectedGroup = group

      if @selectedGroup
        item = @itemForGroup(@selectedGroup)
        if item and item != @selectedItem
          @selectedItem?.el.classList.remove('selected')
          item.el.classList.add('selected')
          @selectedItem = item
      else
        @selectedItem?.el.classList.remove('selected')
        @selectedItem = null

  setGroups: (groups) =>
    currentYear = null
    verticalLineViewHeight = 0

    addYearView = (year) =>
      yearView = new View(tag: 'p', className: 'yearView')
      yearView.text(year)
      @containerView.addSubview(yearView)

    for group in groups
      do (group) =>
        date = new Date(group.date)
        if currentYear? and currentYear != date.getFullYear()
          verticalLineViewHeight += 36
          addYearView(currentYear)

        itemView = new View(tag: 'a', group: group)
        itemView.el.addEventListener('click', =>
          @trigger('click', group)
        )

        textView = new View(tag: 'span', className: 'textView')
        textView.text(group.name)
        itemView.addSubview(textView)

        dateView = new View(tag: 'span', className: 'dateView')

        monthString = months[date.getMonth()].toUpperCase()

        dateView.text("#{monthString} #{date.getFullYear()}")
        itemView.addSubview(dateView)

        circleView = new View(tag: 'span', className: 'circleView')
        itemView.addSubview(circleView)

        verticalLineViewHeight += 36

        @containerView.addSubview(itemView)

        currentYear = date.getFullYear()

    addYearView(currentYear) if currentYear?

    @verticalLineView.el.style.height = (verticalLineViewHeight - 36) + "px"

  itemForGroup: (group) =>
    for view in @containerView.subviews
      continue if !view.options.group?
      return view if view.options.group.path == group.path
    null

  updateCanvasSize: =>
    @canvas.el.width = 95 * pixelRatio
    @canvas.el.height = @canvas.height() * pixelRatio

  center: =>
    height = @height()
    @marginTop = height * 0.4
    @marginTop = Math.max(16, @marginTop)
    @containerView.el.style.marginTop = "#{@marginTop}px"
    @verticalLineView.el.style.marginTop = "#{@marginTop}px"

  redraw: =>
    requestAnimationFrame =>
      @draw(@ctx)

  draw: (ctx) =>
    if !@isVisible()
      return

    canvasWidth = @canvas.el.width / pixelRatio
    canvasHeight = @canvas.el.height / pixelRatio

    ctx.fillStyle = 'white'
    if @lastDrawnRect?
      ctx.fillRect.apply(ctx, @lastDrawnRect)
    else
      ctx.fillRect(0, 0, canvasWidth * pixelRatio, canvasHeight * pixelRatio)

    if !@visibleGroups? or @visibleGroups.length == 0
      @lastDrawnRect = [0,0,0,0]
      return

    fullRect = null
    for group in @visibleGroups
      item = @itemForGroup(group.group)
      continue unless item?

      itemRect = item.frame()
      itemRect.y += @translateY
      groupRect = group.rect

      if group.group == @selectedGroup
        ctx.strokeStyle = '#0091FF'
        ctx.lineWidth = '3'
      else
        ctx.strokeStyle = "rgba(176, 176, 176, #{Math.min(1, group.portion * 4)})"
        ctx.lineWidth = '1'

      y1 = itemRect.y + itemRect.height / 2
      y2 = groupRect.y + groupRect.height / 2
      minY = Math.min(y1, y2) - 5
      maxY = Math.max(y1, y2) + 5
      rect = [0, minY * pixelRatio, 95 * pixelRatio, (maxY - minY) * pixelRatio ]

      if fullRect?
        newHeight = Math.max(fullRect[3] + fullRect[1], rect[3] + rect[1]) - Math.min(fullRect[1], rect[1])
        minY = Math.min(fullRect[1], rect[1])
        fullRect = [fullRect[0], minY, rect[2], newHeight]
      else
        fullRect = rect

      @drawLine(ctx, { x: 0, y: y1 }, { x: 95, y: y2 })

    @lastDrawnRect = fullRect

  drawLine: (ctx, from, to) =>
    from = multiply(from, pixelRatio)
    to = multiply(to, pixelRatio)
    midX = (from.x + to.x) / 2 + from.x
    ctx.beginPath()
    ctx.moveTo(from.x, from.y)
    ctx.bezierCurveTo(midX, from.y, midX, to.y, to.x, to.y)
    ctx.stroke()
    ctx.closePath()

  # Events
  onResize: =>
    @updateCanvasSize()
    @center()
    @redraw()

  onScroll: =>
    scrollY = scroll.value.y
    height = document.body.clientHeight - getWindowSize().height
    percent = scrollY / height

    @translateY = roundf(-percent * (@containerView.height() - @marginTop), 2)
    transform = "translate3d(0,"+@translateY+"px,0)"

    @containerView.el.style.webkitTransform = transform
    @verticalLineView.el.style.webkitTransform = transform

module.exports = TimelineView
