module.exports = (xs..., fs, callback) ->
  [p, last] = [0, fs.length - 1]

  getStart = ->
    if fs.length is 0 then callback else makePipe(fs[0])

  getNext = ->
    if p is last then callback else makePipe(fs[++p])

  makePipe = (f) ->
    (e, xs...) ->
      if e then callback(e)
      else safely -> f(xs..., getNext())

  safely = (f) ->
    try f() catch error then callback(error)

  getStart()(null, xs...)

