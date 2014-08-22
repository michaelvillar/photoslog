Controller = require('controller')
View = require('view')
PhotosGroupsView = require('photosGroupsView')
TimelineView = require('timelineView')
get = require('get')
router = require('router')
scroll = require('scroll')

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

    @bindEvents()

  bindEvents: =>
    @timelineView.on('click', @onClick)
    @timelineView.on('selectedGroupDidChange', @onSelectedGroupDidChange)
    scroll.on('change', @onScroll)

  setSelectedGroup: (group) =>
    @timelineView.setSelectedGroup(group)
    scroll.to(
      y: @photosGroupsView.groupViewY(group),
      views: [@photosGroupsView]
    )
    @onScroll()

  scrollToSelectedGroup: =>

  # Private
  updateVisibleGroups: =>
    @timelineView.setVisibleGroups(@photosGroupsView.visibleGroups())

  # Events
  onScroll: =>
    requestAnimationFrame =>
      @updateVisibleGroups()

  onClick: (group) =>
    router.goToGroup(group)

  onSelectedGroupDidChange: (group) =>
    return if scroll.scrolling
    router.goToGroup(group, { trigger: false })

module.exports = Timeline
