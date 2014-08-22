EventDispatcher = require('eventDispatcher')

router = new EventDispatcher

router.goToHome = ->
  router.goTo({}, "")

router.goToGroup = (group) ->
  if !group?
    return router.goToHome()
  state = {
    obj: group,
    type: 'group'
  }
  router.goTo(state, "/#{group.path}")

router.goTo = (state, url) ->
  return if JSON.stringify(router.state) == JSON.stringify(state)
  history.pushState(state, "", url)
  router.state = state
  router.trigger('change', state)

router.state = {}

window.addEventListener 'popstate', (e) =>
  router.state = e.state
  router.trigger('change', e.state)

module.exports = router
