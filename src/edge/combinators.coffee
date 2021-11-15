import { curry, rtee } from "@dashkite/joy/function"
import { isObject } from "@dashkite/joy/value"
import { merge } from "@dashkite/joy/object"

assignIndexGraphite = curry rtee (name, { type, value }, context) ->
  context[ name ] = "#{type}::#{value}"
  assignStashGraphite [ name ]: { type, value }, context

assignStashGraphite = curry rtee (value, context) ->
  context.stash ?= {}
  context.stash.graphite ?= {}
  assign context.stash.graphite, value

beginsWith = curry rtee (value, context) ->
  context.beginsWith = value

build = (fx) ->
  pipe [
    -> {}
    fx...
  ]

created = curry rtee (value, context) ->
  if isObject value
    context.created = value.created
  else
    context.created = value

direction = curry rtee (value, context) ->
  context.direction = value

edge = curry rtee (value, context) ->
  context.edge = value

expiresAt = curry rtee (value, context) ->
  if isObject value
    context.expiresAt = value.expiresAt
  else
    context.expiresAt = value

limit = curry rtee (value, context) ->
  context.limit = value

origin = curry rtee (value, context) ->
  assignIndexGraphite "origin", value, context

plainData = curry rtee (value, context) ->
  context.plainData = value

range = curry rtee ({ before, after }, context) ->
  context.range = { before, after }

returnNext = curry rtee (value, context) ->
  context.returnNext = value

secondary = curry rtee (value, context) ->
  assignIndexGraphite "secondary", value, context

sort = curry rtee (value, context) ->
  switch value
    when "primary"
      context.sort = "primary"
      context.ascending = true
    when "reverse-primary"
      context.sort = "primary"
      context.ascending = false
    when "secondary"
      context.sort = "secondary"
      context.ascending = true
    when "reverse-secondary"
      context.sort = "secondary"
      context.ascending = false
    else
      throw new Error "unknown graphite sort model [#{value}]"

startAfter = curry rtee (value, context) ->
  context.startAfter = value

stash = curry rtee (value, context) ->
  context.stash ?= {}
  context.stash.manual ?= {}
  assign context.stash.manual, value

target = curry rtee (value, context) ->
  assignIndexGraphite "target", value, context

updated = curry rtee (value, context) ->
  if isObject value
    context.updated = value.updated
  else
    context.updated = value

vertex = curry rtee (value, context) ->
  assignIndexGraphite "vertex", value, context


{
  assignIndexGraphite
  assignStashGraphite
  beginsWith
  build
  created 
  direction 
  edge
  expiresAt 
  limit
  origin
  plainData
  range
  returnNext
  secondary
  sort
  startAfter
  stash 
  target
  update
  vertex
}