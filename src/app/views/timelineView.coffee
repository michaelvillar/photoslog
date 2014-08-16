View = require('view')

months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

class TimelineView extends View
  className: 'timelineView'

  constructor: ->
    super

    verticalLineView = new View(tag: 'span', className: 'verticalLineView')
    @addSubview(verticalLineView)

  setGroups: (groups) =>
    groups = groups.reverse()
    for group in groups
      itemView = new View(tag: 'a')

      textView = new View(tag: 'span', className: 'textView')
      textView.text(group.name)
      itemView.addSubview(textView)

      dateView = new View(tag: 'span', className: 'dateView')

      date = new Date(group.date)
      monthString = months[date.getMonth()].toUpperCase()

      dateView.text("#{monthString} #{date.getFullYear()}")
      itemView.addSubview(dateView)

      circleView = new View(tag: 'span', className: 'circleView')
      itemView.addSubview(circleView)

      @addSubview(itemView)

module.exports = TimelineView
