Controller = require('controller')
View = require('view')
Timeline = require('timeline')
Fullscreen = require('fullscreen')
router = require('router')

class App extends Controller
  constructor: ->
    super

    @view = new View({ el: document.body, className: 'appView' })

    @timeline = new Timeline
    @view.addSubview(@timeline.view)

    @fullscreen = new Fullscreen
    @view.addSubview(@fullscreen.view)

    @bindEvents()

  bindEvents: =>
    @timeline.on('photoClick', @onPhotoClick)
    router.on('change', @onRouterChange)

  # Events
  onRouterChange: (state) =>
    if state?.type == 'group'
      @timeline.setSelectedGroup(state.obj)
    else
      @timeline.setSelectedGroup(null)

  onPhotoClick: (timelineView, view, image) =>
    @fullscreen.open(image, {
      view: view
    })

module.exports = App
