import assert from "@dashkite/assert"
import { client } from "../helpers"

builder = ->
  q = client.queryCombinators

  expected = 
    Limit: 10
    ProjectionExpression: "#0,#2,#3,#4,#5"
    ScanIndexForward: true
    KeyConditionExpression: "#0 = :0 AND #1 > :1"
    ExpressionAttributeNames:
      "#0": "origin"
      "#1": "typeTarget" 
      "#2": "typeOrigin" 
      "#3": "target" 
      "#4": "created" 
      "#5": "name" 
    ExpressionAttributeValues:
      ":0": S: "foobar"
      ":1": S: "hello"

  query = do q.build [
    q.limit 10
    q.include [ "origin", "typeOrigin", "target", "created", "name" ]
    q.sortDirection "ascending"
    q.partitionKey
      key: "origin"
      value: "foobar"
    q.sortKey
      key: "typeTarget"
      type: "gt"
      value: "hello"
  ]

  assert.deepEqual expected, query

export { builder }