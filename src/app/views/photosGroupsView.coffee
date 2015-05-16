View = require('view')
PhotosGroupView = require('photosGroupView')
Queue = require('queue')

class PhotosGroupsView extends View
  className: 'photosGroupsView'

  constructor: ->
    super

    @queue = new Queue
    @queue.maxConcurrent = 5

  setGroups: (groups) =>
    for group in groups
      photosGroupView = new PhotosGroupView(group: group, queue: @queue)
      photosGroupView.on('click', @onClick)
      @addSubview(photosGroupView)

  # `anyVisibleGroup` and `visibleGroups` is a way to get the visible groups with
  # limited calls to `visibleBounds` which is costy
  anyVisibleGroup: =>
    if @lastVisibleGroup? and @lastVisibleGroup.visibleBounds()?
      return @lastVisibleGroup
    else
      if @lastVisibleGroup?
        aroundIndex = @subviews.indexOf(@lastVisibleGroup)
      else
        aroundIndex = -1

      i = 1

      inRange = (index) =>
        index >= 0 && index < @subviews.length
      checkView = (view) =>
        visibleBounds = view.visibleBounds()
        if visibleBounds?
          @lastVisibleGroup = view
          return true
        return null

      while true
        upIndex = aroundIndex + i
        downIndex = aroundIndex - i

        upIndexInRange = inRange(upIndex)
        downIndexInRange = inRange(downIndex)

        if !upIndexInRange && !downIndexInRange
          return null

        if upIndexInRange
          view = @subviews[upIndex]
          if checkView(view)?
            return view

        if downIndexInRange
          view = @subviews[downIndex]
          if checkView(view)?
            return view

        i +=1

    return null

  visibleGroups: =>
    view = @anyVisibleGroup()
    return [] unless view?

    visibleGroups = [view]
    cachedVisibleBounds = {}

    index = @subviews.indexOf(view)
    cachedVisibleBounds[index] = view.visibleBounds()

    k = 0

    for i in [index-1..0] by -1
      break if i < 0
      k += 1
      view = @subviews[i]
      visibleBounds = view.visibleBounds()
      if visibleBounds?
        cachedVisibleBounds[i] = visibleBounds
        visibleGroups.push(view)
      else
        break
    for i in [index+1..@subviews.length-1] by 1
      break if i >= @subviews.length
      k += 1
      view = @subviews[i]
      visibleBounds = view.visibleBounds()
      if visibleBounds?
        cachedVisibleBounds[i] = visibleBounds
        visibleGroups.push(view)
      else
        break

    visibleGroups = visibleGroups.sort (a, b) =>
      if @subviews.indexOf(a) > @subviews.indexOf(b)
        return 1
      else
        return -1

    return visibleGroups.map (view) =>
      visibleBounds = cachedVisibleBounds[@subviews.indexOf(view)]
      {
        group: view.options.group,
        rect: visibleBounds,
        portion: visibleBounds.height / view.height()
      }

  groupViewY: (group) =>
    view = @viewForGroup(group)
    if view?
      view.y() - 45
    else
      0

  # Private
  viewForGroup: (group) =>
    for view in @subviews
      return view if view.options.group.path == group?.path

  # Events
  onClick: (photosGroupView, view, image) =>
    @trigger('click', @, view, image)

module.exports = PhotosGroupsView
