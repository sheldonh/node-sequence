assert = require('assert')
module.paths.push('lib')
waterfall = require('waterfall')

describe "waterfall", ->

  it "calls back empty without any functions to sequence", (done) ->
    waterfall (e, any) ->
      assert.ifError(e)
      assert !any?
      done()

  it "calls back empty with an empty list of functions to sequence", (done) ->
    waterfall [], (e, any) ->
      assert.ifError(e)
      assert !any?
      done()

  it "calls through with only one function to sequence", (done) ->
    waterfall [
      (c) -> c(null, "the", "key", "to", "wisdom")
    ], (e, xs...) ->
      assert.ifError(e)
      assert.deepEqual xs, ["the", "key", "to", "wisdom"]
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
    waterfall [
      (c) -> c(null, "head")
      (i, c) -> c(null, i + "body")
      (i, c) -> c(null, i + "tail")
    ], (e, x) ->
      assert.ifError(e)
      assert.equal x, "headbodytail"
      done()

  it "sequences variadic functions", (done) ->
    waterfall [
      (c) -> c(null, "twin", "heads")
      (xs..., c) -> c(null, xs..., "big", "scaly", "body")
      (xs..., c) -> c(null, xs..., "one tail")
    ], (e, xs...) ->
      assert.ifError e
      assert.deepEqual xs, ["twin", "heads", "big", "scaly", "body", "one tail"]
      done()

  it "short circuits on error", (done) ->
    started = false
    ranFullCourse = false
    waterfall [
      (c) -> started = true; c()
      (c) -> c(new Error("Failed"))
      (c) -> ranFullCourse = true; c(null, "the impossible response")
    ], (e, x) ->
      assert e?
      assert started
      assert !ranFullCourse
      assert !x?
      done()

  it "catches an error and calls it back", (done) ->
    started = false
    ranFullCourse = false
    waterfall [
      (c) -> started = true; c()
      (c) -> throw new Error("Failed")
      (c) -> ranFullCourse = true; c(null, "the impossible response")
    ], (e, x) ->
      assert e?
      assert started
      assert !ranFullCourse
      assert !x?
      done()

