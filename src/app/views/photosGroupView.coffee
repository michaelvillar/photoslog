View = require('view')

class PhotosGroupView extends View
  className: 'photosGroupView'

  render: =>
    pixelRatio = window.devicePixelRatio ? 1
    ratio = "#{pixelRatio}x"
    i = 0
    for travelImage in @options.group.images
      image = document.createElement('div')
      image.classList.add('image')
      image.classList.add(travelImage.type)
      if travelImage.type == 'row'
        rowsLength = (@options.group.images.length - 1)
        image.style.width = "calc((100% - #{7 * (rowsLength - 1)}px) / #{rowsLength})"

      image.style.backgroundImage = "url(" + ["/data", @options.group.path, travelImage.files[ratio]].join('/') + ")";
      @el.appendChild(image)
      i += 1

module.exports = PhotosGroupView
