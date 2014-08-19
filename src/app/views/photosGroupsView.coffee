View = require('view')
PhotosGroupView = require('photosGroupView')

class PhotosGroupsView extends View
  className: 'photosGroupsView'

  setGroups: (groups) =>
    for group in groups
      photosGroupView = new PhotosGroupView({ group: group })
      @addSubview(photosGroupView)

  visibleGroups: =>
    visibleGroups = []
    for view in @subviews
      visibleBounds = view.visibleBounds()
      if visibleBounds?
        visibleGroups.push({
          group: view.options.group,
          rect: visibleBounds
        })
    visibleGroups

module.exports = PhotosGroupsView
