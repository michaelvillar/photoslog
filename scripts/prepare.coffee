#!/usr/bin/env ./node_modules/coffee-script/bin/coffee

easyimage = require 'easyimage'
fs = require 'fs'

BASE = './'
SRC =  "#{BASE}data/"
DST = "#{BASE}public/data/"

fs.readdir SRC, (err, dirs) ->
  if err?
    return console.log err

  for dir in dirs
    continue if dir == '.DS_Store'
    fullDir = SRC + dir + "/"
    dstDir = DST + dir + "/"
    fs.readdir fullDir, (err, files) ->
      return if err?
      fs.mkdir dstDir, ->
        for file in files
          continue if file == '.DS_Store'
          if file == 'info.json'
            info = new Info(fullDir, file)
            info.write(dstDir)
          else
            image = new Image(fullDir, file)
            image.resize(dstDir, {
              width: 200
            })

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
    @path = path
    @filename = filename
    @filepath = @path + @filename

class Info extends File
  write: (dstPath) =>
    fs.writeFile dstPath + "info.json", ""

class Image extends File
  resize: (dstPath, opts = {}) =>
    for ratio in [1, 2]
      do =>
        options = clone(opts)
        suffix = if ratio == 1 then '' else "@#{ratio}x"
        filenameArgs = @filename.split('.')
        suffixedFilename = ''
        for i, arg of filenameArgs
          if parseInt(i) == filenameArgs.length - 1
            suffixedFilename += suffix
          if i > 0
            suffixedFilename += '.'
          suffixedFilename += arg

        options.src = @filepath
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
