#!/usr/bin/env ./node_modules/coffee-script/bin/coffee

fs = require('fs')
Mincer = require('mincer')

environment = new Mincer.Environment()
environment.appendPath('src/app')

class JSPostProcessor
  constructor: (@path, @data) ->

  evaluate: (context, locals) =>
    if(this.path.match(/nomodule/))
      return this.data
    pathArgs = this.path.split("/")
    name = pathArgs[pathArgs.length - 1].replace(".coffee","")
    data = 'this.require.define({ "'+name+'" : function(exports, require, module) {'
    data += this.data
    data += '}});'
    return data

environment.registerPostProcessor('application/javascript', JSPostProcessor)

commonjsData = fs.readFileSync('scripts/data/commonjs.nomodule.js')

setInterval ->
  try
    asset = environment.findAsset('app.nomodule.coffee')
    fs.writeFile "public/js/app.js", commonjsData + asset.toString()
    console.log 'Compiled app.js'
    asset = environment.findAsset('app.styl')
    fs.writeFile "public/css/app.css", asset.toString()
    console.log 'Compiled app.css'
  catch e
    console.log e
, 1000
