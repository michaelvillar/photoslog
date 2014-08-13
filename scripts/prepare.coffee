#!/usr/bin/env ./node_modules/coffee-script/bin/coffee

easyimage = require 'easyimage'
fs = require 'fs'

BASE = './'
SRC =  "#{BASE}data/"
DST = "#{BASE}public/data/"

clone = (obj) ->
  JSON.parse(JSON.stringify(obj))

class Queue
  constructor: ->
    @fns = []
    @processing = false
    @parallel = 4
    @current = 0

  add: (fn) =>
    @fns.push(fn)
    @start()

  start: =>
    while @current < @parallel and @fns.length > 0
      @process()

  process: =>
    if @fns.length == 0
      return
    if @current >= @parallel
      return
    fn = @fns.shift()
    @current += 1
    fn =>
      @current -= 1
      @process()

imagesQueue = new Queue

class File
  constructor: (path, filename) ->
    @_path = path
    @_filename = filename
    @_filepath = @_path + @_filename

class TimelineFile extends File
  constructor: ->
    super
    @travels = []

  addTravel: (travel) =>
    @travels.push {
      name: travel.name(),
      path: travel.path(),
      images: travel.timelineImages()
    }

  write: (dstPath) =>
    fs.writeFile dstPath + "photos.json", JSON.stringify({ travels: @travels })

class TravelFile extends File
  constructor: ->
    super

    @json = JSON.parse(fs.readFileSync(@_filepath))

  name: =>
    @json.name

  path: =>
    args = @_path.trim().split('/')
    i = args.length - 1
    while i > 0
      return args[i] if args[i] != ''
      i -= 1
    ''

  timelineImages: =>
    images = []
    for i in [0..2]
      break if i >= @json.images.length
      image = @json.images[i]
      images.push image
    images

  write: (dstPath) =>
    fs.writeFile dstPath + "info.json", JSON.stringify(@json)

class ImageFile extends File
  resize: (dstPath, opts = {}, others = {}) =>
    for ratio in [1, 2]
      do =>
        others.suffix ?= ''
        options = clone(opts)
        suffix = if ratio == 1 then '' else "@#{ratio}x"
        filenameArgs = @_filename.split('.')
        suffixedFilename = ''
        for i, arg of filenameArgs
          if parseInt(i) == filenameArgs.length - 1
            suffixedFilename += others.suffix + suffix
          if i > 0
            suffixedFilename += '.'
          suffixedFilename += arg

        options.src = @_filepath
        options.dst = dstPath + suffixedFilename
        options.quality = 95
        for key in ['width', 'height', 'cropwidth', 'cropheight', 'x', 'y']
          options[key] *= ratio if options[key]?

        fs.exists options.dst, (exists) ->
          return if exists
          imagesQueue.add (fn) =>
            easyimage.resize options, (err, image) ->
              if err?
                console.log err
              else
                console.log "Generated #{image.name.trim()}"
              fn()

timelineFile = new TimelineFile

dirs = fs.readdirSync SRC
for dir in dirs
  continue if dir == '.DS_Store'
  fullDir = SRC + dir + "/"
  dstDir = DST + dir + "/"
  files = fs.readdirSync fullDir
  fs.mkdirSync dstDir unless fs.existsSync dstDir
  for file in files
    continue if file == '.DS_Store'
    if file == 'info.json'
      travelFile = new TravelFile(fullDir, file)
      timelineFile.addTravel(travelFile)
      travelFile.write(dstDir)
    else
      imageFile = new ImageFile(fullDir, file)
      imageFile.resize(dstDir, {
        width: 380
      }, {
        suffix: '_timeline'
      })

timelineFile.write(DST)
