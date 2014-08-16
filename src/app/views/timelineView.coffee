View = require('view')

class TimelineView extends View
  className: 'timelineView'

  constructor: ->
    super

    verticalLineView = new View(tag: 'span', className: 'verticalLineView')
    @addSubview(verticalLineView)

  setGroups: (groups) =>
    for group in groups
      itemView = new View(tag: 'a')

      textView = new View(tag: 'span', className: 'textView')
      textView.text(group.name)
      itemView.addSubview(textView)

      dateView = new View(tag: 'span', className: 'dateView')
      dateView.text('AUG 2013')
      itemView.addSubview(dateView)

      circleView = new View(tag: 'span', className: 'circleView')
      itemView.addSubview(circleView)

      @addSubview(itemView)

module.exports = TimelineView
