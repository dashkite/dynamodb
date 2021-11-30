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

# The edge is mostly self-sufficent in managing its own "indexData". 
# It just needs to know what "plainData" you'd lke stuff into this record and 
# their type declarations.  
model =
  properties:
    author: "S"
    title: "S"
    secondary: "S" # Overwrite check.

client = Core.edge model

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

_generate = (data) ->
  e = client.combinators
  do e.build [
    e.origin 
  ]

generate = (count, context) ->
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