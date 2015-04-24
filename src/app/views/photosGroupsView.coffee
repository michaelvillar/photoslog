View = require('view')
PhotosGroupView = require('photosGroupView')
Queue = require('queue')

class PhotosGroupsView extends View
  className: 'photosGroupsView'

  constructor: ->
    super

    @queue = new Queue

  setGroups: (groups) =>
    for group in groups
      photosGroupView = new PhotosGroupView(group: group, queue: @queue)
      photosGroupView.on('click', @onClick)
      @addSubview(photosGroupView)

  visibleGroups: =>
    visibleGroups = []
    for view in @subviews
      visibleBounds = view.visibleBounds()
      if visibleBounds?
        visibleGroups.push({
          group: view.options.group,
          rect: visibleBounds,
          portion: visibleBounds.height / view.height()
        })
    visibleGroups

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
