#!/usr/bin/env ./node_modules/coffee-script/bin/coffee

compile = require('../lib/compile')

compile()
setInterval ->
  try
    compile()
  catch e
    console.log e
, 1000
