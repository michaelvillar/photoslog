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

cancelScroll = (e) ->
  scroll = { x: window.scrollX, y: window.scrollY }
  e.preventDefault()
  document.removeEventListener('scroll', cancelScroll)
  setTimeout ->
    window.scrollTo(scroll.x, scroll.y)
  , 1

window.addEventListener 'popstate', (e) =>
  # document.addEventListener('scroll', cancelScroll)
  router.state = e.state
  router.trigger('change', e.state)

module.exports = router
