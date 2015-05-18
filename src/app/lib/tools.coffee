module.exports = {}

module.exports.roundf = (v, decimal) ->
  d = Math.pow(10, decimal)
  return Math.round(v * d) / d
