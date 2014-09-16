EventDispatcher = require('eventDispatcher')
scroll = require('scroll')

router = new EventDispatcher

router.goToHome = (options = {}) ->
  router.goTo({}, "", options)

router.goToGroup = (group, options = {}) ->
  if !group?
    return router.goToHome()
  state = {
    obj: group,
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

window.addEventListener 'popstate', (e) =>
  router.state = e.state
  router.trigger('change', e.state)

module.exports = router
