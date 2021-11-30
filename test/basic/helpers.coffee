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
  key: [ "origin", "typeTarget" ]
  properties:
    origin: "S"
    target: "S"
    typeTarget: "S"
    typeOrigin: "S"
    secondary: "S"
    created: "S"
    updated: "S"
    stash: "JSON"
    expiresAt: "N"
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
  secondary = created

  { origin, target, typeTarget, typeOrigin, type, created, secondary, name }

generate = (count, type) ->
  A = await client.put ( await prepare type )
  results = [ A ]
  for i in [1...count]
    results.push ( await client.put ( await prepare type, origin: A.origin ) )
  results

export { 
  generateID, generate,
  model, Core, client, prepare
  allEqual, areAscending
}