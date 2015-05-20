module.exports = {}

module.exports.roundf = (v, decimal) ->
  d = Math.pow(10, decimal)
  return Math.round(v * d) / d

module.exports.merge = (a, b) ->
  c = {}
  for k, v of a
    c[k] = v
  for k, v of b
    c[k] = v
  c
