Controller = require('controller')
View = require('view')
Main = require('main')

class App extends Controller
  constructor: ->
    super

    # document.addEventListener 'touchmove', (e) ->
    #   e.preventDefault()

    @view = new View({ el: document.body, className: 'appView' })

    @mainController = new Main()
    @view.addSubview(@mainController.view)

    @overlayView = new View(className: 'overlayView')
    @overlayView.del.css(opacity: 0)
    @view.addSubview(@overlayView)

    @mainController.on('push', @onPush)

    @modalViews = []

  push: =>
    @mainController.view.del.to({
      scale: 0.95
    }, {
      type: dynamic.Spring,
      duration: 600
    }).start()

    @overlayView.el.style.pointerEvents = 'auto'
    @overlayView.del.to({
      opacity: 1
    }, {
      type: dynamic.EaseInOut,
      duration: 200
    }).start()

    modalView = new View({ className: 'modalView' })
    for i in [1..100]
      itemView = new View(className: 'itemView')
      itemView.text("Item ##{i}")
      itemView.el.addEventListener('click', @push)
      modalView.addSubview(itemView)

    modalView.del.css(translateX: 100, opacity: 0)
    @view.addSubview(modalView)
    modalView.del.to({
      opacity: 1
    }, {
      type: dynamic.EaseInOut,
      duration: 200
    }).to({
      translateX: 0
    }, {
      type: dynamic.Spring,
      frequency: 5,
      friction: 330,
      duration: 600
    }).start()

    modalView.el.addEventListener('touchstart', @onTouchStart)
    modalView.el.addEventListener('touchmove', @onTouchMove)
    modalView.el.addEventListener('touchend', @onTouchEnd)

    @modalViews.push(modalView)

  popModalView: =>
    modalView = @modalViews[@modalViews.length - 1]
    modalView.del.to({
      opacity: 0
    }, {
      type: dynamic.EaseInOut,
      duration: 200,
      complete: =>
        modalView.detach()
    }).start()

    @modalViews.pop()

    if @modalViews.length == 0
      @overlayView.el.style.pointerEvents = 'none'
      @mainController.view.del.to({
        scale: 1
      }, {
        type: dynamic.Spring,
        duration: 600
      }).start()

      @overlayView.del.to({
        opacity: 0
      }, {
        type: dynamic.EaseInOut,
        duration: 200
      }).start()

  onPush: =>
    @push()

  onTouchStart: (e) =>
    touch = e.touches[0]
    @clientX = touch.clientX

  onTouchMove: (e) =>
    touch = e.touches[0]
    @lastX = x = touch.clientX - @clientX
    modalView = @modalViews[@modalViews.length - 1]
    modalView.del.css(translateX: x) #, rotateZ: x / 30)

  onTouchEnd: =>
    modalView = @modalViews[@modalViews.length - 1]
    if Math.abs(@lastX) > 50
      @popModalView()
    else
      modalView.del.to({
        translateX: 0
      }, {
        type: dynamic.Spring,
        friction: 330,
        duration: 600
      }).start()

module.exports = App
