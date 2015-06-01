Controller = require('controller')
View = require('view')
LoadingView = require('loadingView')
Timeline = require('timeline')
Fullscreen = require('fullscreen')
ForkView = require('forkView')
router = require('router')
config = require('config')

class App extends Controller
  constructor: ->
    super

    config.imagesRootPath = @options.imagesRootPath

    @view = new View({ el: document.body, className: 'appView' })

    @timeline = new Timeline
    @view.addSubview(@timeline.view)

    loadingViewContainer = new View(className: 'loadingViewContainer')
    @view.addSubview(loadingViewContainer)
    @loadingView = new LoadingView
    loadingViewContainer.addSubview(@loadingView)

    @fullscreen = new Fullscreen
    @fullscreen.delegate = @timeline
    @fullscreen.on('progress', @onFullscreenLoadingProgress)
    @view.addSubview(@fullscreen.view)

    @forkView = new ForkView
    @view.addSubview(@forkView)

    @bindEvents()

  bindEvents: =>
    @timeline.on('photoClick', @onPhotoClick)
    @timeline.on('load', @onLoad)
    router.on('change', @onRouterChange)
    window.addEventListener('keydown', @onKeyDown)

  # Events
  onRouterChange: (state) =>
    if state?.type == 'group'
      @timeline.setSelectedGroupFromPath(state.obj)
    else
      @timeline.setSelectedGroupFromPath(null)

  onPhotoClick: (timelineView, view, image) =>
    @fullscreen.open(image, {
      view: view
    })

  onKeyDown: (e) =>
    if @fullscreen.hidden
      if e.keyCode == 37 or e.keyCode == 38
        @timeline.selectPrevious()
        e.preventDefault()
        e.stopPropagation()
      else if e.keyCode == 39 or e.keyCode == 40
        @timeline.selectNext()
        e.preventDefault()
        e.stopPropagation()
      else if e.keyCode == 32
        o = @timeline.currentImage()
        @fullscreen.open(o.image, o.options)
        e.preventDefault()
        e.stopPropagation()

  onLoad: =>
    @options.onLoad?()

  onFullscreenLoadingProgress: (progress) =>
    if progress == 100
      @loadingView.setValue(0)
    else
      @loadingView.setValue(progress / 100)

module.exports = App
