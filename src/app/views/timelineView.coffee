View = require('view')

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
pixelRatio = window.devicePixelRatio ? 1

multiply = (obj, value) ->
  newObj = {}
  for k, v of obj
    newObj[k] = v * value
  newObj

class TimelineView extends View
  className: 'timelineView'

  constructor: ->
    super

    @canvas = new View(tag: 'canvas', className: 'curvedLinesCanvas')
    @ctx = @canvas.el.getContext("2d")
    @addSubview(@canvas)

    verticalLineView = new View(tag: 'span', className: 'verticalLineView')
    @addSubview(verticalLineView)

    @selectedGroup = null

    window.addEventListener('resize', @updateCanvasSize)
    setTimeout =>
      @updateCanvasSize()
    , 100

  setVisibleGroups: (groups) =>
    groups.sort (a, b) ->
      a.rect.y > b.rect.y
    @visibleGroups = groups

    @selectedGroup = null
    maxPortion = 0
    maxGroup = null
    for group in groups
      if group.portion > 0.66
        @selectedGroup = group.group
        break

      if group.portion > maxPortion
        maxPortion = group.portion
        maxGroup = group.group

    @selectedGroup = maxGroup if !@selectedGroup

    if @selectedGroup
      item = @itemForGroup(@selectedGroup)
      if item and item != @selectedItem
        @selectedItem?.el.classList.remove('selected')
        item.el.classList.add('selected')
        @selectedItem = item
    else
      @selectedItem?.el.classList.remove('selected')
      @selectedItem = null

    @draw(@ctx)

  setGroups: (groups) =>
    currentYear = null

    addYearView = (year) =>
      yearView = new View(tag: 'p', className: 'yearView')
      yearView.text(year)
      @addSubview(yearView)

    for group in groups
      itemView = new View(tag: 'a', group: group)

      textView = new View(tag: 'span', className: 'textView')
      textView.text(group.name)
      itemView.addSubview(textView)

      dateView = new View(tag: 'span', className: 'dateView')

      date = new Date(group.date)
      monthString = months[date.getMonth()].toUpperCase()

      dateView.text("#{monthString} #{date.getFullYear()}")
      itemView.addSubview(dateView)

      circleView = new View(tag: 'span', className: 'circleView')
      itemView.addSubview(circleView)

      @addSubview(itemView)

      if currentYear? and currentYear != date.getFullYear()
        addYearView(currentYear)

      currentYear = date.getFullYear()

    addYearView(currentYear) if currentYear?

  itemForGroup: (group) =>
    for view in @subviews
      return view if view.options.group == group
    null

  updateCanvasSize: =>
    @canvas.el.width = 95 * pixelRatio
    @canvas.el.height = @canvas.height() * pixelRatio
    @draw(@ctx)

  draw: (ctx) =>
    canvasWidth = @canvas.el.width / pixelRatio
    canvasHeight = @canvas.el.height / pixelRatio
    ctx.clearRect(0, 0, canvasWidth * pixelRatio, canvasHeight * pixelRatio)

    return if !@visibleGroups? or @visibleGroups.length == 0

    for group in @visibleGroups
      item = @itemForGroup(group.group)
      continue unless item?

      itemRect = item.frame()
      groupRect = group.rect

      if group.group == @selectedGroup
        ctx.strokeStyle = '#0091FF'
        ctx.lineWidth = '3'
      else
        ctx.strokeStyle = '#B0B0B0'
        ctx.lineWidth = '1'

      @drawLine(ctx, { x: 0, y: itemRect.y + itemRect.height / 2 }, { x: 95, y: groupRect.y + groupRect.height / 2 })

  drawLine: (ctx, from, to) =>
    from = multiply(from, pixelRatio)
    to = multiply(to, pixelRatio)
    midX = (from.x + to.x) / 2 + from.x
    ctx.beginPath()
    ctx.moveTo(from.x, from.y)
    ctx.bezierCurveTo(midX, from.y, midX, to.y, to.x, to.y)
    ctx.stroke()
    ctx.closePath()

module.exports = TimelineView
