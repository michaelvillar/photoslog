EventDispatcher = require('eventDispatcher')

class Queue extends EventDispatcher
  constructor: ->
    @jobs = []
    @runningJobs = []
    @maxConcurrent = 2

  addJob: (job) =>
    @jobs.push(job)
    @tick()

  tick: =>
    return if @maxConcurrent <= @runningJobs.length
    return if @jobs.length <= 0

    job = @jobs[0]
    @jobs.splice(0, 1)
    @runningJobs.push(job)
    job =>
      pos = @runningJobs.indexOf(job)
      @runningJobs.splice(pos, 1)
      @tick()

module.exports = Queue
