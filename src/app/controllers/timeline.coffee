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
    @setSelectedGroup(@previousGroup())

  selectNext: =>
    @setSelectedGroup(@nextGroup())

  previousGroup: =>
    if @timelineView.selectedGroup?
      index = @groups.indexOf(@timelineView.selectedGroup) - 1
      index = Math.max(0, index)
    else
      index = 0
    @groups[index]

  nextGroup: =>
    if @timelineView.selectedGroup?
      index = @groups.indexOf(@timelineView.selectedGroup) + 1
      index = Math.min(@groups.length - 1, index)
    else
      index = 0
    @groups[index]

  currentImage: =>
    image = @timelineView.selectedGroup.images[0]
    o = @images.filter (i) ->
      i.image == image
    o[0]

  previousImage: (image) =>
    o = @images.filter (i) ->
      i.image == image
    index = @images.indexOf(o[0])
    if index > 0
      index -= 1
      @images[index]
    else
      null

  nextImage: (image) =>
    o = @images.filter (i) ->
      i.image == image
    index = @images.indexOf(o[0])
    if index < @images.length - 1
      index += 1
      @images[index]
    else
      null

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

    @images = []
    for group in @groups
      for image in group.images
        @images.push({
          image: image,
          options: {
            view: @photosGroupsView.imageViewForImage(image, group)
          }
        })

    if router.state?.type == 'group'
      @setSelectedGroupFromPath(router.state.obj, { animated: false })
    else
      @updateVisibleGroups()
    @trigger('load')

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
