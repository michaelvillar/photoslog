Controller = require('controller')
View = require('view')
PhotosGroupsView = require('photosGroupsView')
TimelineView = require('timelineView')
get = require('get')

class Timeline extends Controller
  constructor: ->
    super

    @view = new View

    @timelineView = new TimelineView
    @view.addSubview(@timelineView)

    @photosGroupsView = new PhotosGroupsView
    @view.addSubview(@photosGroupsView)

    get '/data/info.json', (data) =>
      groups = data.groups.reverse()

      @photosGroupsView.setGroups(groups)
      @timelineView.setGroups(groups)
      @updateVisibleGroups()

    window.addEventListener('scroll', @onScroll)

  # Private
  updateVisibleGroups: =>
    @timelineView.setVisibleGroups(@photosGroupsView.visibleGroups())

  # Events
  onScroll: =>
    @updateVisibleGroups()

module.exports = Timeline
