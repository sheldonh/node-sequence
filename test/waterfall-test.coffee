assert = require('assert')
module.paths.push('lib')
waterfall = require('waterfall')

describe "waterfall", ->

  it "calls back verbatim without any functions to sequence", (done) ->
    waterfall "head", "body", "tail", [], (e, xs...) ->
      assert.ifError(e)
      assert.deepEqual xs, ["head", "body", "tail"]
      done()

  it "calls through with only one function to sequence", (done) ->
    waterfall "head", "body", "tail", [(xs..., c) -> c(null, xs.join(''))], (e, xs...) ->
      assert.ifError(e)
      assert.deepEqual xs, ["headbodytail"]
      done()

  it "sequences nullary functions", (done) ->
    seen = {}
    waterfall [
      (c) -> seen.a = true; c()
      (c) -> seen.b = true; c()
      (c) -> seen.c = true; c()
    ], (e, x) ->
      assert.ifError(e)
      assert.deepEqual seen, {a: true, b: true, c: true}
      done()

  it "sequences unary functions", (done) ->
    waterfall "head", [
      (i, c) -> c(null, i + "body")
      (i, c) -> c(null, i + "tail")
    ], (e, x) ->
      assert.ifError(e)
      assert.equal x, "headbodytail"
      done()

  it "sequences variadic functions", (done) ->
    waterfall "twin", "heads", [
      (xs..., c) -> c(null, xs.join(''), "big", "scaly", "body")
      (xs..., c) -> c(null, xs.join(''), "many", "tails")
    ], (e, xs...) ->
      assert.ifError e
      assert.deepEqual xs, ["twinheadsbigscalybody", "many", "tails"]
      done()

  it "short circuits on error", (done) ->
    started = false
    ranFullCourse = false
    waterfall "head", [
      (xs..., c) -> started = true; c()
      (xs..., c) -> c(new Error("Failed"))
      (xs..., c) -> ranFullCourse = true; c(null, xs + "tail")
    ], (e, x) ->
      assert e?
      assert started
      assert !ranFullCourse
      assert !x?
      done()

  it "catches an error and calls it back", (done) ->
    waterfall "head", [
      (i, c) -> throw new Error("Failed")
    ], (e, x) ->
      assert e?
      assert !x?
      done()

