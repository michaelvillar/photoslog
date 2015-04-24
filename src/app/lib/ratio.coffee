pixelRatio = window.devicePixelRatio ? 1
pixelRatio = {1:1, 2:2}[pixelRatio] ? 1
module.exports = "#{pixelRatio}x"
