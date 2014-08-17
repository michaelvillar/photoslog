Controller = require('controller')
View = require('view')
Timeline = require('timeline')
get = require('get')

class App extends Controller
  constructor: ->
    super

    @view = new View({ el: document.body, className: 'appView' })
    @timeline = new Timeline
    @view.addSubview(@timeline.view)

module.exports = App
