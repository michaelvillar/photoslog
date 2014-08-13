View = require('view')

class TravelView extends View
  className: 'travelView'

  render: =>
    pixelRatio = window.devicePixelRatio ? 1
    suffix = if pixelRatio == 1 then '' else "@#{pixelRatio}x"
    i = 0
    for travelImage in @options.travel.images
      image = document.createElement('div')
      image.classList.add('image')
      image.classList.add(travelImage.type)
      if travelImage.type == 'row'
        image.style.width = Math.round(100 / (@options.travel.images.length - 1)) + "%"
      # else
        # image.style.width = @options.travel.images.length - 1

      args = travelImage.file.split('.')
      filename = args[0]
      extension = "." + args[1]

      image.style.backgroundImage = "url(" + ["/data", @options.travel.path, filename + "_timeline" + suffix + extension].join('/') + ")";
      @el.appendChild(image)
      i += 1

module.exports = TravelView
