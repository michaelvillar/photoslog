View = require('view')
PhotosGroupView = require('photosGroupView')

class TimelineView extends View
  className: 'timelineView'

  setPhotos: (groups) =>
    for group in groups
      photosGroupView = new PhotosGroupView({ group: group })
      @addSubview(photosGroupView)

module.exports = TimelineView
