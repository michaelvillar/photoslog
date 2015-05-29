EventDispatcher = require('eventDispatcher')

class Queue extends EventDispatcher
  constructor: ->
    @jobs = []
    @runningJobs = []
    @maxConcurrent = 2

  cancelAllJobs: =>
    for entry in @jobs
      entry.options.cancelled?()
    @jobs = []

  addJob: (job, options = {}) =>
    @jobs.push({ job: job, options: options })
    @tick()

  tick: =>
    return if @maxConcurrent <= @runningJobs.length
    return if @jobs.length <= 0

    entry = @jobs[0]
    job = entry.job
    @jobs.splice(0, 1)
    @runningJobs.push(job)
    job =>
      entry.options.complete?()
      pos = @runningJobs.indexOf(job)
      @runningJobs.splice(pos, 1)
      @tick()

module.exports = Queue
