import { curry } from "@dashkite/joy/function"
import { isEmpty } from "@dashkite/joy/value"
import { isSet } from "@dashkite/joy/type"
import { decode as decodeBase64, encode as encodeBase64 } from "@dashkite/base64"

isNotEmpty = (x) -> !( isEmpty x )

toDynamoDB =
  S: (s) -> S: s.toString()
  N: (n) -> N: n.toString()
  BOOL: (b) -> BOOL: b
  B: (b) -> B: encodeBase64 b
  M: (m) -> M: m
  L: (l) -> L: l
  SS: (ax) ->
    ax = Array.from ax if isSet ax
    SS: (a.toString() for a in ax)
  NS: (ax) ->
    ax = Array.from ax if isSet ax
    NS: (a.toString() for a in ax)
  BS: (ax) ->
    ax = Array.from ax if isSet ax
    BS: (encodeBase64 a for a in ax) 
  
  # Extension of DynamoDB types to stringify objects. 
  # _ version used with wrap only.
  JSON: (o) -> S: JSON.stringify o
  _JSON: (s) -> S: s

fromDynamoDB = curry (model, data) ->
  result = {}

  for name, typedObject of data
    type = model[ name ]

    for inlineType, value of typedObject
      result[ name ] = switch type
        when "S", "BOOL" then value
        when "N" then Number value
        when "B" then decodeBase64 value
        when "SS" then new Set value
        when "NS" then new Set (Number item for item in value)
        when "BS" then new Set (decodeBase64 item for item in value)
        when "L" then ( fromDynamoDB model, item for item in value )
        when "M" then fromDynamoDB model, value

        # Extension of DynamoDB types to stringify objects.
        when "JSON" then JSON.parse value
        
        # Failure
        else
          throw new Error "Unable to map DynamoDB attribute type: #{type}"
      break

  result


# Accept an incoming object to store in DynamoDB, rejecting fields that do not 
# have a defined type or are null.
# This does not provide full type validation, merely null checks.
# From AWS DynamoDB documentation:
# > Attribute values cannot be null. 
# > String and Binary type attributes must have lengths greater than zero. 
# > Set type attributes cannot be empty.

wrap = curry (model, data) ->
  result = {}

  for name, value of data
    type = model[name]

    if type? && value?
      switch type
        when "S", "SS", "NS", "BS", "B"
          if isNotEmpty value
            result[ name ] = toDynamoDB[ type ] value
        when "N"
          result[ name ] = toDynamoDB.N value
        when "BOOL"
          result[ name ] = toDynamoDB.BOOL value
        when "M"
          if isNotEmpty value
            map = wrap model, value
            result[ name ] = toDynamoDB.M  map
        when "L"
          if isNotEmpty value
            list = ( wrap model, item for item in value )
            result[ name ] = toDynamoDB.L list
        
        # We already stringify to check for empty string, so use _JSON.
        when "JSON"
          string = JSON.stringify value
          if isNotEmpty string
            result[ name ] = toDynamoDB._JSON string

        # Failure
        else
          throw new Error "Unable to wrap field '#{name}'. Unknown DyanmoDB data type, '#{type}'"
  
  result


unwrap = fromDynamoDB

export {
  toDynamoDB, fromDynamoDB,
  wrap, unwrap
}

