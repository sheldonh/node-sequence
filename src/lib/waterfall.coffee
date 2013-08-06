module.exports = (args...) ->
  fv = args[args.length - 2] or []
  callback = args[args.length - 1]

  [p, last] = [0, fv.length - 1]

  getNext = ->
    if p is last then callback else makePipe(fv[++p])

  makePipe = (f) ->
    (e, args...) ->
      if e then callback(e)
      else safely -> f(args..., getNext())

  safely = (f) ->
    try f() catch error then callback(error)

  entryPoint = if fv.length is 0 then callback else makePipe(fv[0])
  entryPoint()

