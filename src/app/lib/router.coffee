EventDispatcher = require('eventDispatcher')
scroll = require('scroll')

router = new EventDispatcher

router.goToHome = (options = {}) ->
  router.goTo({}, "", options)

router.goToGroup = (group, options = {}) ->
  if !group?
    return router.goToHome()
  state = {
    obj: group.path,
    type: 'group'
  }
  router.goTo(state, "/#{group.path}", options)

router.goTo = (state, url, options = {}) ->
  options.trigger ?= true
  return if JSON.stringify(router.state) == JSON.stringify(state)
  history.pushState(state, "", url)
  router.state = state
  router.trigger('change', state) if options.trigger

router.state = {}

parse = ->
  path = window.location.pathname
  match = path.match(/\/([^\/]*)\/?/)
  if match? and match[1]? and match[1].length > 0
    router.state = {
      obj: match[1] + '/',
      type: 'group'
    }

init = ->
  window.addEventListener 'popstate', (e) =>
    router.state = e.state
    router.trigger('change', e.state)

  parse()

init()

module.exports = router
