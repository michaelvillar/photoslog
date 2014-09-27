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

    @view = new View(className: 'mainView')

    @timelineView = new TimelineView
    @view.addSubview(@timelineView)

    @photosGroupsContainerView = new View(className: 'photosGroupsContainerView')
    @photosGroupsView = new PhotosGroupsView

    @photosGroupsContainerView.addSubview(@photosGroupsView)
    @view.addSubview(@photosGroupsContainerView)

    get '/data/info.json', (data) =>
      @groups = data.groups.reverse()

      @photosGroupsView.setGroups(@groups)
      @timelineView.setGroups(@groups)
      if router.state?.type == 'group'
        @setSelectedGroup(router.state.obj, { animated: false })
      else
        @updateVisibleGroups()

    @bindEvents()

  bindEvents: =>
    @timelineView.on('click', @onClick)
    @timelineView.on('selectedGroupDidChange', @onSelectedGroupDidChange)
    scroll.on('change', @onScroll)

  setSelectedGroup: (path, options = {}) =>
    options.animated ?= true
    group = @groupFromPath(path)
    @timelineView.setSelectedGroup(group)
    scroll.to(
      y: @photosGroupsView.groupViewY(group),
      views: [@photosGroupsView],
      animated: options.animated
    )
    @onScroll()

  scrollToSelectedGroup: =>

  # Private
  groupFromPath: (path) =>
    for group in @groups
      return group if group.path == path

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
