moduleKeywords = ['extended', 'included']

class Module
  @extend: (obj) ->
    for name, func of obj when name not in moduleKeywords
      @[name] = func

    obj.extended?.apply(@)
    this

  @include: (obj) ->
    for name, func of obj when name not in moduleKeywords
      # Assign properties to the prototype
      @::[name] = func

    obj.included?.apply(@)
    this

module.exports = Module
