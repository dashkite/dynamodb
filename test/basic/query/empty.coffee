import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import { client, generate } from "../helpers"

empty = ->
  q = client.queryCombinators

  items = await generate 3, "basic-table-query"
  { origin } = items[0]

  query = do q.build [
    q.limit 2
    q.include [ "origin", "typeTarget", "created", "name" ]
    q.sortDirection "ascending"
  ]

  try
    await client.query query
  catch error
    assert /KeyConditions or KeyConditionExpression/.test error.toString()

export { empty }