Controller = require('controller')
TimelineView = require('timelineView')
get = require('get')

class Timeline extends Controller
  constructor: ->
    super

    @view = new TimelineView

    get '/data/info.json', (data) =>
      @view.setPhotos(data.groups)

module.exports = Timeline
