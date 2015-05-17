Controller = require('controller')
View = require('view')
PhotosGroupsView = require('photosGroupsView')
TimelineView = require('timelineView')
get = require('get')
router = require('router')
scroll = require('scroll')
config = require('config')

class Timeline extends Controller
  constructor: ->
    super

    @scrolling = false

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
    get config.imagesRootPath + 'info.json', @onLoad

  bindEvents: =>
    @timelineView.on('click', @onClick)
    @timelineView.on('selectedGroupDidChange', @onSelectedGroupDidChange)
    @photosGroupsView.on('click', @onPhotoClick)
    scroll.on('change', @onScroll)
    window.addEventListener('resize', @onResize)

  setSelectedGroupFromPath: (path, options = {}) =>
    group = @groupFromPath(path)
    @setSelectedGroup(group, options)

  setSelectedGroup: (group, options = {}) =>
    options.animated ?= true
    options.directClick ?= false
    @timelineView.setSelectedGroup(group)
    @scrolling = true
    scroll.to(
      y: @photosGroupsView.groupViewY(group),
      views: [@photosGroupsView],
      animated: options.animated,
      complete: =>
        @scrolling = false
    )
    @onScroll()

  selectPrevious: =>
    if @timelineView.selectedGroup?
      index = @groups.indexOf(@timelineView.selectedGroup) - 1
      index = Math.max(0, index)
    else
      index = 0
    @setSelectedGroup(@groups[index])

  selectNext: =>
    if @timelineView.selectedGroup?
      index = @groups.indexOf(@timelineView.selectedGroup) + 1
      index = Math.min(@groups.length - 1, index)
    else
      index = 0
    @setSelectedGroup(@groups[index])

  # Private
  groupFromPath: (path) =>
    return unless @groups
    for group in @groups
      return group if group.path == path

  updateVisibleGroups: =>
    @timelineView.setVisibleGroups(@photosGroupsView.visibleGroups(), {
      autoSelect: !@scrolling
    })

  # Events
  onLoad: (data) =>
    @groups = data.groups.reverse()

    @photosGroupsView.setGroups(@groups)
    @timelineView.setGroups(@groups)
    if router.state?.type == 'group'
      @setSelectedGroupFromPath(router.state.obj, { animated: false })
    else
      @updateVisibleGroups()

  onScroll: =>
    requestAnimationFrame (t) =>
      @updateVisibleGroups()

  onResize: =>
    requestAnimationFrame (t) =>
      @updateVisibleGroups()

  onClick: (group) =>
    router.goToGroup(group)

  onSelectedGroupDidChange: (group) =>
    # return if scroll.scrolling
    # router.goToGroup(group, { trigger: false })

  onPhotoClick: (photosGroupView, view, image) =>
    @trigger('photoClick', @, view, image)

module.exports = Timeline
