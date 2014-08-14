View = require('view')
PhotosGroupView = require('photosGroupView')

class PhotosGroupsView extends View
  className: 'photosGroupsView'

  setGroups: (groups) =>
    for group in groups
      photosGroupView = new PhotosGroupView({ group: group })
      @addSubview(photosGroupView)

module.exports = PhotosGroupsView
