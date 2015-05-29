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

  loadImages: =>
    view = @anyVisibleGroup()
    return unless view?

    @queue.cancelAllJobs()
    view.loadImages()

    i = @subviews.indexOf(view)
    k = 0
    while true
      k += 1
      next = if i + k < @subviews.length then @subviews[i + k] else null
      previous = if i - k >= 0 then @subviews[i - k] else null

      next.loadImages() if next?
      previous.loadImages() if previous?

      break if !next? and !previous?

  visibleGroups: =>
    view = @anyVisibleGroup()
    return [] unless view?

    visibleGroups = [view]
    cachedVisibleBounds = {}

    index = @subviews.indexOf(view)
    cachedVisibleBounds[index] = view.visibleBounds()

    addViews = (range, incr) =>
      k = 0
      cont = true

      checkView = (view) =>
        if cont
          visibleBounds = view.visibleBounds()
          if visibleBounds?
            cachedVisibleBounds[i] = visibleBounds
            visibleGroups.push(view)
          else
            cont = false
        unless cont
          k += 1
        if k > 2
          return false
        true

      for i in range by incr
        break if i < 0
        break if i >= @subviews.length
        view = @subviews[i]
        if !checkView(view)
          break

    # Next views first
    addViews([index+1..@subviews.length-1], 1)
    # Then previous views
    addViews([index-1..0], -1)

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

  imageViewForImage: (image, group) =>
    view = @viewForGroup(group)
    view.imageViewForImage(image)

  # Private
  viewForGroup: (group) =>
    for view in @subviews
      return view if view.options.group.path == group?.path

  # Events
  onClick: (photosGroupView, view, image) =>
    @trigger('click', @, view, image)

module.exports = PhotosGroupsView
