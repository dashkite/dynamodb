import assert from "@dashkite/assert"
import * as _ from "@dashkite/joy"
import { confidential } from "panda-confidential"
import graphiteCore from "../../src/index"

Confidential = confidential()

generateID = -> 
  Confidential.convert from: "bytes", to: "base36", 
    await Confidential.randomBytes 16

Core = graphiteCore 
  table: "graphite-library-test"
  aws: 
    region: 'us-east-1'

model =
  key: ["origin", "typeTarget"]
  types:
    origin: "S"
    target: "S"
    typeTarget: "S"
    typeOrigin: "S"
    created: "S"
    stash: "JSON"
    dynamoExpires: "N"
    name: "S"
    type: "S"

client = Core.basic model

allEqual = (value, ax) ->
  for a in ax
    return false if _.notEqual a, value
  true

areAscending = (ax) ->
  for a, i in ax when i < ( ax.length - 1 )
    return false if a > ax[ i + 1 ]
  true

prepare = (type, { origin, target, name, created } = {}) ->
  origin ?= await generateID()
  target ?= await generateID()
  name ?= await generateID()
  typeTarget = "#{type}::#{target}"
  typeOrigin = "#{type}::#{origin}"
  created ?= new Date().toISOString()

  { origin, target, typeTarget, typeOrigin, type, created, name }

generate = (count, type) ->
  A = await client.put ( await prepare type )
  results = [ A ]
  for i in [1...count]
    results.push ( await client.put ( await prepare type, origin: A.origin ) )
  results

GPD = ->
  data = await prepare "basic-gpd"
  { origin, typeTarget } = data
  
  # Null Get
  assert.deepEqual undefined, await client.get { origin, typeTarget }
  
  # Put on new item
  assert.deepEqual data, await client.put data

  # Get 
  assert.deepEqual data, await client.get { origin, typeTarget }

  # Put on existing item
  data.created = new Date().toISOString()
  assert.deepEqual data, await client.put data
  assert.deepEqual data, await client.get { origin, typeTarget }

  # Delete on existing item
  assert.deepEqual undefined, await client.delete data
  assert.deepEqual undefined, await client.get { origin, typeTarget }

  # Delete on non-existing item
  assert.deepEqual undefined, await client.delete data


queryBuilder = ->
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

tableQuery = ->
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
  assert "origin" in _.keys next
  assert "typeTarget" in _.keys next

indexQuery = ->
  q = client.queryCombinators

  items = await generate 5, "basic-index-query"
  { typeOrigin, origin } = items[0]

  query = do q.build [
    q.fromIndex "OutEdgesByTime"
    q.include [ "origin", "typeTarget", "created" ]
    q.sortDirection "ascending"
    q.partitionKey
      key: "typeOrigin"
      value: typeOrigin
  ]

  { results, next } = await client.query query

  assert.equal 5, results.length
  assert allEqual origin, _.project "origin", results
  assert areAscending _.project "created", results
  assert !next?


  query = do q.build [
    q.fromIndex "OutEdgesByTime"
    q.include [ "origin", "typeTarget", "created" ]
    q.sortDirection "ascending"
    q.partitionKey
      key: "typeOrigin"
      value: typeOrigin
    q.sortKey
      key: "created"
      type: "between"
      value: results[1].created
      value2: results[3].created
  ]

  { results, next } = await client.query query
  
  assert.equal 3, results.length
  assert allEqual origin, _.project "origin", results
  assert areAscending _.project "created", results
  assert !next?


  

export { GPD, queryBuilder, tableQuery, indexQuery }