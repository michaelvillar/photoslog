Controller = require('controller')
View = require('view')
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

    @fullscreen = new Fullscreen
    @fullscreen.delegate = @timeline
    @view.addSubview(@fullscreen.view)

    @forkView = new ForkView
    @view.addSubview(@forkView)

    @bindEvents()

  bindEvents: =>
    @timeline.on('photoClick', @onPhotoClick)
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

module.exports = App
