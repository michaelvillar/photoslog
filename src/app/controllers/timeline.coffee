Controller = require('controller')
View = require('view')
PhotosGroupsView = require('photosGroupsView')
TimelineView = require('timelineView')
get = require('get')
router = require('router')

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
    window.addEventListener('scroll', @onScroll)

  setSelectedGroup: (group) =>
    clearTimeout(@timeout)
    @timelineView.setSelectedGroup(group)
    window.scrollTo(0, @photosGroupsView.groupViewY(group))
    @onScroll()

  scrollToSelectedGroup: =>

  # Private
  updateVisibleGroups: =>
    @timelineView.setVisibleGroups(@photosGroupsView.visibleGroups())

  # Events
  onScroll: =>
    @updateVisibleGroups()

  onClick: (group) =>
    router.goToGroup(group)

  onSelectedGroupDidChange: (group) =>
    clearTimeout(@timeout)
    @timeout = setTimeout ->
      router.dontTrigger ->
        router.goToGroup(group)
    , 100

module.exports = Timeline
