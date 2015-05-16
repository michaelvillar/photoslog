#!/usr/bin/env ./node_modules/coffee-script/bin/coffee
compile = require('../lib/compile')
watchTree = require("fs-watch-tree").watchTree
argv = require('argv')
args = argv.option([{
  name: 'watch',
  short: 'w',
  type: 'boolean'
}]).run()

build = ->
  compile (e) ->
    console.log(e) if e?

if args.options.watch
  watchTree "src/app/", (e) ->
    console.log("\nFile changed: " + e.name)
    build()

build()
