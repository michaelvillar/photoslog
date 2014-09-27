Controller = require('controller')
View = require('view')

class Fullscreen extends Controller
  constructor: ->
    super

    @view = new View(className: 'fullscreenView')

  openImage: (image, fromView) =>

module.exports = Fullscreen
