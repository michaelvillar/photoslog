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
    if e.keyCode == 38
      @timeline.selectPrevious()
      e.preventDefault()
    else if e.keyCode == 40
      @timeline.selectNext()
      e.preventDefault()
      e.stopPropagation()

module.exports = App
