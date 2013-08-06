module.exports = (args...) ->
  fv = args[args.length - 2] or []
  callback = args[args.length - 1]

  f = (i) ->
    if i is fv.length
      callback
    else
      (e, args...) ->
        if e? then callback(e)
        else fv[i](args..., f(i + 1))

  try f(0)()
  catch e then callback(e)

