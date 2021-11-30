import assert from "@dashkite/assert"
import { client } from "../helpers"

e = client.combinators

declare = ->
  expected = 
    origin: "author::Arnold Weber"
    edge: "author"
    target: "host::Dolores"
    secondary: "created::2015-05-23T00:00:00.000Z"
    stash:
      graphite:
        origin: type: "author", value: "Arnold Weber"
        target: type: "host", value: "Dolores"
        secondary: type: "created", value: "2015-05-23T00:00:00.000Z"

  context = do e.build [
    e.origin type: "author", value: "Robert Ford"
    e.edge "author"
    e.target type: "host", value: "Dolores"
    e.secondary type: "created", value: "2015-05-23T00:00:00.000Z"
  ]

  console.log context

  assert.deepEqual expected, context

outPrimary = ->
  # expected = 
  #   origin: "author::Arnold Weber"
  #   edge: "author"
  #   target: "host::Dolores"
  #   stash:
  #     graphite:
  #       origin: type: "author", value: "Arnold Weber"
  #       target: type: "host", value: "Dolores"

  # assert.deepEqual expected, do e.build [
  #   e.vertex type: "author", value: "Robert Ford"
  #   e.edge "author"
  #   e.direction "out"
  #   e.sort "primary"
  # ]

test = ->
  declare()
  outPrimary()
 

export { test as context }


# beginsWith: set "beginsWith"
# created: set "created"
#-- direction: set "direction"
#-- edge: set "edge"
# expiresAt: set "expiresAt"
# isConsistent: set "isConistent"
# limit: set "limit"
#-- origin: setIndex "origin"
# plainData: set "plainData"
# range: range
# returnNext: set "returnNext"
# secondary: setIndex "secondary"
#-- sort: sort
# startAfter: set "startAfter"
# stash: setStash "manual"
#-- target: setIndex "target"
# updated: set "updated"
# vertex: setIndex "vertex"