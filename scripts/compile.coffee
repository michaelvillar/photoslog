#!/usr/bin/env ./node_modules/coffee-script/bin/coffee
compile = require('../lib/compile')
watchTree = require("fs-watch-tree").watchTree

build = ->
  compile (e) ->
    console.log(e) if e?

watchTree "src/app/", (e) ->
  console.log("\nFile changed: " + e.name)
  build()

build()
