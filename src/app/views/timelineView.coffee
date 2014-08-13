View = require('view')
TravelView = require('travelView')

class TimelineView extends View
  className: 'timelineView'

  setTravels: (travels) =>
    for travel in travels
      travelView = new TravelView({ travel: travel })
      @addSubview(travelView)

module.exports = TimelineView
