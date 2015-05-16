View = require('view')
ImageView = require('imageView')
ratio = require('ratio')
months = require('months')
config = require('config')

class PhotosGroupView extends View
  className: 'photosGroupView'

  constructor: ->
    super
    @loaded = false

  render: =>
    @label = new View(tag: 'h2')
    @label.text(@options.group.name)
    @addSubview(@label)

    @date = new View(tag: 'span')
    date = new Date(@options.group.date)
    monthString = months[date.getMonth()].toUpperCase()
    @date.text("#{monthString} #{date.getFullYear()}")
    @label.addSubview(@date)

    @appendFullImage(@options.group.images[0])
    @appendRowImages(@options.group.images[1..@options.group.images.length - 1])

  bindEvents: =>
    window.addEventListener('resize', @invalidate)
    window.addEventListener('resize', @layout)
    @on('addedToDOM', @layout)

  appendFullImage: (image) =>
    @fullImage = image
    image.view = @createImageView(image)
    @addSubview(image.view)

  appendRowImages: (images) =>
    @images = images
    margins = (@images.length - 1) * 7

    totalWidthAt1000 = 0
    # Process ratios
    for image in @images
      image.ratio = image.size.width / image.size.height
      totalWidthAt1000 += 1000 * image.ratio
    for image in @images
      image.layout =
        widthPercent: 1000 * image.ratio / totalWidthAt1000

    # Render
    for i, image of @images
      image.view = @createImageView(image)
      @addSubview(image.view)
      image.view.el.style.width = "calc((100% - #{margins}px) * #{image.layout.widthPercent})"

  layout: =>
    return if !@images[0].view.width()

    margins = (@images.length - 1) * 7

    # Layout
    height = @images[0].view.width() / @images[0].ratio
    for i, image of @images
      image.view.el.style.height = "#{height}px"

    @fullImage.view.el.style.height = "#{@fullImage.size.height / @fullImage.size.width * @fullImage.view.width()}px"

  createImageView: (image) =>
    filePath = image.files[ratio]
    imageView = new ImageView(
      className: image.type,
      queue: @options.queue,
      imagePath: config.imagesRootPath + filePath,
      object: image
    )
    imageView.on('click', @onClick)
    imageView

  loadImages: =>
    return if @loaded
    @loaded = true
    for i, image of @images
      image.view.load()
    @fullImage.view.load()

  invalidate: =>
    @cachedFrame = null

  frame: =>
    if !@cachedFrame
      @cachedFrame = super
    @cachedFrame

  # Events
  onClick: (imageView) =>
    window.open(imageView.options.imagePath, "_blank")

module.exports = PhotosGroupView
