Controller = require('controller')
PhotosGroupsView = require('photosGroupsView')
get = require('get')

class Timeline extends Controller
  constructor: ->
    super

    @view = new PhotosGroupsView

    get '/data/info.json', (data) =>
      @view.setGroups(data.groups)

module.exports = Timeline
