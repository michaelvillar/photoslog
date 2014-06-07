Controller = require('controller')
View = require('view')

class App extends Controller
  constructor: ->
    super

    @view = new View({ el: document.body })

module.exports = App
