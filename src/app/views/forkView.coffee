View = require('view')

class ForkView extends View
  tag: 'a'
  className: 'forkView'

  constructor: ->
    super

    @text("Fork me on Github")
    @el.href = "https://github.com/michaelvillar/photoslog"
    @el.target = "_blank"

module.exports = ForkView
