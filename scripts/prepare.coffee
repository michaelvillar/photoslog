#!/usr/bin/env ./node_modules/coffee-script/bin/coffee

easyimage = require 'easyimage'
fs = require 'q-io/fs'
Q = require 'q'
_ = require 'lodash'

BASE = './'
SRC =  "#{BASE}data/"
DST = "#{BASE}public/data/"

clone = (obj) ->
  JSON.parse(JSON.stringify(obj))

start = ->
  fs.list(SRC).then((dirs) ->
    console.log('Finding info.json files')
    Q.all do ->
      for dir in dirs
        continue if dir == '.DS_Store'
        parseGroup(dir)
  ).then((groups) ->
    console.log('Creating timeline...')
    createTimeline(groups)
  ).then(->
    console.log('Done!')
  )

parseGroup = (dir) ->
  groupDir = SRC + dir + "/"
  dstGroupDir = DST + dir + "/"
  fs.exists(groupDir + "info.json")
  .then((exists) ->
    return false unless exists
    fs.exists(dstGroupDir)
  ).then((exists) ->
    return true if exists
    fs.makeDirectory(dstGroupDir)
  ).then(->
    console.log "Parsing #{groupDir + "info.json"}"
    parseInfoFile(groupDir, "info.json")
  ).then((json) ->
    ps = for image in json.images
      console.log "Copying #{dstGroupDir + image.file}"
      fs.copy(groupDir + image.file, dstGroupDir + image.file)

    console.log "Writing #{dstGroupDir + "info.json"}"
    ps.push(fs.write(dstGroupDir + "info.json", JSON.stringify(json)))

    json.path = dir + "/"

    Q.all(ps).then(-> json)
  ).catch((e) ->
    console.log(e)
  )

parseInfoFile = (groupDir, fileName, dstDir) ->
  infoFilePath = groupDir + fileName
  returnJson = null
  fs.read(infoFilePath).then((data) ->
    JSON.parse(data)
  ).then((json) ->
    returnJson = json
    Q.all do ->
      for image in json.images
        do (image) =>
          easyimage.info(groupDir + image.file).then((info) =>
            image.size =
              width: info.width
              height: info.height
          )
  ).then(->
    returnJson
  )

createTimeline = (groups) ->
  json = { groups: [] }
  for group in groups
    json.groups.push(clone(group))

  Q.all(
    _.flatten do ->
      for group in json.groups
        images = group.images
        group.images = []
        for i in [0..Math.min(2, images.length - 1)]
          image = images[i]
          group.images.push(image)
          processTimelineImage(group, image)
  ).then(->
    console.log "Writing #{DST + "info.json"}"
    fs.write(DST + "info.json", JSON.stringify(json))
  )

processTimelineImage = (group, image) ->
  srcFile = SRC + group.path + image.file
  dstPath = DST + group.path
  resizeImage(srcFile, dstPath, {
    width: 380
  }, {
    suffix: '_timeline'
  })

resizeImage = (file, dstPath, opts = {}, others = {}) =>
  Q.all do ->
    for ratio in [1, 2]
      do ->
        others.suffix ?= ''
        options = clone(opts)
        suffix = if ratio == 1 then '' else "@#{ratio}x"
        fileArgs = file.split('/')
        filename = fileArgs[fileArgs.length - 1]
        filenameArgs = filename.split('.')
        suffixedFilename = ''
        for i, arg of filenameArgs
          if parseInt(i) == filenameArgs.length - 1
            suffixedFilename += others.suffix + suffix
          if i > 0
            suffixedFilename += '.'
          suffixedFilename += arg

        options.src = file
        options.dst = dstPath + suffixedFilename
        console.log "Resizing #{options.src} to #{options.dst}"
        options.quality = 95
        for key in ['width', 'height', 'cropwidth', 'cropheight', 'x', 'y']
          options[key] *= ratio if options[key]?

        fs.exists(options.dst)
        .then((exists) ->
          return if exists
          easyimage.resize(options)
        )

start()
