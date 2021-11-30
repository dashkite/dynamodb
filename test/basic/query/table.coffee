import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import { client, generate } from "../helpers"

table = ->
  q = client.queryCombinators

  items = await generate 3, "basic-table-query"
  { origin } = items[0]

  query = do q.build [
    q.limit 2
    q.include [ "origin", "typeTarget", "created", "name" ]
    q.sortDirection "ascending"
    q.partitionKey
      key: "origin"
      value: origin
  ]

  { results, next } = await client.query query

  sortKeys = _.project "typeTarget", results
  remaining = items.find (a) -> a.typeTarget not in sortKeys

  assert.equal 2, results.length
  assert.equal origin, results[0].origin
  assert.equal origin, results[1].origin
  assert results[0].typeTarget < results[1].typeTarget
  assert results[1].typeTarget < remaining.typeTarget
  assert next?
  assert "origin" in Object.keys next
  assert "typeTarget" in Object.keys next

export { table }