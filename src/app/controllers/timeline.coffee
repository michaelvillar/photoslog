Controller = require('controller')
TimelineView = require('timelineView')
get = require('get')

class Timeline extends Controller
  constructor: ->
    super

    @view = new TimelineView

    get '/data/photos.json', (data) =>
      @view.setTravels(data.travels)

module.exports = Timeline
