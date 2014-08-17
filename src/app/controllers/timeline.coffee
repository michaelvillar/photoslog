Controller = require('controller')
View = require('view')
PhotosGroupsView = require('photosGroupsView')
TimelineView = require('timelineView')
get = require('get')

class Timeline extends Controller
  constructor: ->
    super

    @view = new View

    @photosGroupsView = new PhotosGroupsView
    @view.addSubview(@photosGroupsView)

    @timelineView = new TimelineView
    @view.addSubview(@timelineView)

    get '/data/info.json', (data) =>
      @photosGroupsView.setGroups(data.groups)
      @timelineView.setGroups(data.groups)

module.exports = Timeline
