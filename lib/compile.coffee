fs = require('fs')
Mincer = require('mincer')
mkdirp = require('mkdirp')

environment = new Mincer.Environment()
environment.appendPath('src/app')

class JSPostProcessor
  constructor: (@path, @data) ->

  evaluate: (context, locals) =>
    if(this.path.match(/nomodule/))
      return this.data
    pathArgs = this.path.split("/")
    name = pathArgs[pathArgs.length - 1].replace(".coffee","").replace(".js","")
    data = 'this.require.define({ "'+name+'" : function(exports, require, module) {'
    data += this.data
    data += '}});'
    return data

environment.registerPostProcessor('application/javascript', JSPostProcessor)

commonjsData = fs.readFileSync('scripts/data/commonjs.nomodule.js')

saveFile = (path, filename, content, callback) ->
  mkdirp(path, (e) ->
    if e?
      return callback(e)
    fs.writeFile path + "/" + filename, content, callback
  )

module.exports = (callback)->
  try
    asset = environment.findAsset('app.nomodule.coffee')
  catch e
    return callback(e)
  saveFile "public/js", "app.js", commonjsData + asset.toString(), (e) ->
    if(e?)
      return callback(e)
    console.log 'Compiled app.js'

    try
      asset = environment.findAsset('app.styl')
    catch e
      return callback(e)
    saveFile "public/css", "app.css", asset.toString(), (e) ->
      if(e?)
        return callback(e)
      console.log 'Compiled app.css'
      callback(null)
