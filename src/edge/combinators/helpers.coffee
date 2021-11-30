import { curry, rtee, pipe } from "@dashkite/joy/function"
import { isObject } from "@dashkite/joy/type"
import { isEmpty } from "@dashkite/joy/value"
import { merge, mask, assign } from "@dashkite/joy/object"

# Getter to optionally _.get from object or just _.identity value.
get = curry (key, value) ->
  if ( isObject value ) then value[ key ] else value

# Setter to assign a value to main context
set = curry rtee (key, value, context) -> 
  assign context, [ key ]: ( get key, value )

_assign = curry rtee (key, value, context) ->
  assign context, [ key ]: value

setStash = curry rtee (key, value, context) ->
  context.stash ?= {}
  context.stash[ key ] ?= {}
  assign context.stash[ key ], value

setIndex = curry rtee (key, _value, context) ->
  { namespace, type, value, shard  } = _value
  string = "#{namespace}::#{type}::#{value}"
  string += "::#{shard}" if shard?
  context[ key ] = string
  setStash key, { namespace, type, value, shard }, context

 build = (fx) ->
    pipe [
      -> {}
      fx...
    ]

  range = curry rtee (value, context) ->
    keys = [
      "before"
      "after"
      "equal"
      "inclusiveBefore"
      "inclusiveAfter"
      "between"
    ]

    _value = mask keys, value

    if ! isEmpty _value
      context.range = _value 

export {
  set
  _assign as assign
  setStash
  setIndex
  build
  range
}