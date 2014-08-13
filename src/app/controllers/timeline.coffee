Controller = require('controller')
TimelineView = require('timelineView')
get = require('get')

class Timeline extends Controller
  constructor: ->
    super

    @view = new TimelineView

    get '/data/photos.json', (data) =>
      @view.setPhotos(data.groups)

module.exports = Timeline
