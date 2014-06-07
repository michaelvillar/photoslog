EventDispatcher = require('eventDispatcher')

class Controller extends EventDispatcher
  constructor: (options = {}) ->
    super
    @options = options
    @view = null

module.exports = Controller
