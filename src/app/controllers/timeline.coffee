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

    @load()
    @bindEvents()

  load: =>
    get '/data/info.json', @onLoad

  bindEvents: =>
    @timelineView.on('click', @onClick)
    @timelineView.on('selectedGroupDidChange', @onSelectedGroupDidChange)
    @photosGroupsView.on('click', @onPhotoClick)
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
    return unless @groups
    for group in @groups
      return group if group.path == path

  updateVisibleGroups: =>
    @timelineView.setVisibleGroups(@photosGroupsView.visibleGroups())

  # Events
  onLoad: (data) =>
    @groups = data.groups.reverse()

    @photosGroupsView.setGroups(@groups)
    @timelineView.setGroups(@groups)
    if router.state?.type == 'group'
      @setSelectedGroup(router.state.obj, { animated: false })
    else
      @updateVisibleGroups()

  onScroll: =>
    requestAnimationFrame =>
      @updateVisibleGroups()

  onClick: (group) =>
    router.goToGroup(group)

  onSelectedGroupDidChange: (group) =>
    return if scroll.scrolling
    router.goToGroup(group, { trigger: false })

  onPhotoClick: (photosGroupView, view, image) =>
    @trigger('photoClick', @, view, image)

module.exports = Timeline
