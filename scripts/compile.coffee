#!/usr/bin/env ./node_modules/coffee-script/bin/coffee
compile = require('../lib/compile')
compile (e) ->
  console.log(e) if e?
