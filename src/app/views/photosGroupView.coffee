View = require('view')

class PhotosGroupView extends View
  className: 'photosGroupView'

  render: =>
    pixelRatio = window.devicePixelRatio ? 1
    suffix = if pixelRatio == 1 then '' else "@#{pixelRatio}x"
    i = 0
    for travelImage in @options.group.images
      image = document.createElement('div')
      image.classList.add('image')
      image.classList.add(travelImage.type)
      if travelImage.type == 'row'
        rowsLength = (@options.group.images.length - 1)
        image.style.width = "calc((100% - #{7 * (rowsLength - 1)}px) / #{rowsLength})"
      # else
        # image.style.width = @options.group.images.length - 1

      args = travelImage.file.split('.')
      filename = args[0]
      extension = "." + args[1]

      image.style.backgroundImage = "url(" + ["/data", @options.group.path, filename + "_timeline" + suffix + extension].join('/') + ")";
      @el.appendChild(image)
      i += 1

module.exports = PhotosGroupView
