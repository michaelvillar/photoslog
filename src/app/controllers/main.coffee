Controller = require('controller')
View = require('view')
d3 = require('d3.js')

class Main extends Controller
  constructor: ->
    super

    @view = new View(className: 'mainView')

    @navigationBarView = new View(className: 'navigationBarView')
    @navigationBarView.text("Dribbble")
    @view.addSubview(@navigationBarView)

    @tabBarView = new View(className: 'tabBarView')
    @tabBarView.text("Revenue | Customers")
    @view.addSubview(@tabBarView)

    @graphView = new View(className: 'graphView')
    @view.addSubview(@graphView)

    @recentEventsView = new View(className: 'recentEventsView')
    for i in [1..100]
      itemView = new View(className: 'itemView')
      itemView.text("Item ##{i}")
      itemView.el.addEventListener('click', @onItemViewClick)
      @recentEventsView.addSubview(itemView)

    @scrollView = new View(className: 'scrollView')
    @scrollView.addSubview(@recentEventsView)
    @view.addSubview(@scrollView)

    @renderGraph()
    # setInterval @renderGraph, 1000

  renderGraph: =>
    margin = {top: 0, right: 5, bottom: 0, left: 5}
    width = 320 - margin.left - margin.right
    height = 210 - margin.top - margin.bottom

    parseDate = d3.time.format("%d-%b-%y").parse

    x = d3.time.scale().range([0, width])

    y = d3.scale.linear().range([height, 0])

    xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

    yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")

    line = d3.svg.line()
        .x((d) -> return x(d.date))
        .y((d) -> return y(d.close))

    @graphView.text('')
    svg = d3.select(@graphView.el).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    d3.tsv "data/graph.tsv", (error, data) ->
      data.forEach (d) ->
        d.date = parseDate(d.date)
        d.close = +d.close

      x.domain(d3.extent(data, (d) -> return d.date ))
      y.domain(d3.extent(data, (d) -> return d.close ))

      svg.append("path")
          .datum(data)
          .attr("class", "line")
          .attr("d", line)

  onItemViewClick: =>
    @trigger('push')

module.exports = Main
