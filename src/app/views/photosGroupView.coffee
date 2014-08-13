View = require('view')

pixelRatio = window.devicePixelRatio ? 1
ratio = "#{pixelRatio}x"

class PhotosGroupView extends View
  className: 'photosGroupView'

  render: =>
    @appendFullImage(@options.group.images[0])
    @appendRowImages(@options.group.images[1..@options.group.images.length - 1])

  appendFullImage: (image) =>
    @el.appendChild(@createImage(image))

  appendRowImages: (images) =>
    margins = (images.length - 1) * 7

    width = 380 - margins

    totalWidthAt1000 = 0
    # Process ratios
    for image in images
      image.ratio = image.size.width / image.size.height
      totalWidthAt1000 += 1000 * image.ratio
    for image in images
      image.layout =
        widthPercent: 1000 * image.ratio / totalWidthAt1000

    image = images[0]
    height = Math.round(width * image.layout.widthPercent / image.ratio)

    # Layout
    for i, image of images
      w = Math.round(height * image.ratio)
      w = width if parseInt(i) == images.length - 1
      width -= w

      img = @createImage(image)
      img.style.width = "#{w}px"
      img.style.height = "#{height}px"
      @el.appendChild(img)

  createImage: (image) =>
    img = document.createElement('div')
    img.classList.add('image')
    img.classList.add(image.type)
    img.style.backgroundImage = "url(" + ["/data", @options.group.path, image.files[ratio]].join('/') + ")"
    img

module.exports = PhotosGroupView
