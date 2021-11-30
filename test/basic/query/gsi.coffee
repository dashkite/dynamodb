import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import { client, generate, allEqual, areAscending } from "../helpers"

GSI = ->
  q = client.queryCombinators

  items = await generate 5, "basic-index-query"
  { typeOrigin, origin } = items[0]

  query = do q.build [
    q.fromIndex "OutBySecondary"
    q.include [ "origin", "typeTarget", "secondary" ]
    q.sortDirection "ascending"
    q.partitionKey
      key: "typeOrigin"
      value: typeOrigin
  ]

  { results, next } = await client.query query

  assert.equal 5, results.length
  assert allEqual origin, _.project "origin", results
  assert areAscending _.project "secondary", results
  assert !next?


  query = do q.build [
    q.fromIndex "OutBySecondary"
    q.include [ "origin", "typeTarget", "secondary" ]
    q.sortDirection "ascending"
    q.partitionKey
      key: "typeOrigin"
      value: typeOrigin
    q.sortKey
      key: "secondary"
      type: "between"
      value: results[1].secondary
      value2: results[3].secondary
  ]

  { results, next } = await client.query query
  
  assert.equal 3, results.length
  assert allEqual origin, _.project "origin", results
  assert areAscending _.project "secondary", results
  assert !next?

export { GSI }