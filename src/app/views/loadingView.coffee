View = require('view')
tools = require('tools')

class LoadingView extends View
  className: 'loadingView'

  setValue: (value) =>
    @el.style.width = "#{tools.roundf(value * 100, 2)}%"

module.exports = LoadingView
