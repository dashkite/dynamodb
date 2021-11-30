import { merge } from "@dashkite/joy/object"

extendModel = (model) ->
  _properties = {}
  _properties[ "_#{name}" ] = type for name, type of model.properties
  
  key: ["origin", "typeTarget"]
  properties: merge _properties,
    origin: "S"
    target: "S"
    typeTarget: "S"
    typeOrigin: "S"
    secondary: "S"
    created: "S"
    updated: "S"
    stash: "JSON"
    expiresAt: "N"

wrap = (context) ->
  result = {}
  result[ "_#{name}" ] = value for name, value of context.plainData
  result
  
unwrap = (item) ->
  plainData = {}
  indexData = {}
  for name, value of item 
    if name[0] == "_"
      property = _property[1...]
      plainData[ property ] = value
    else
      indexData[ name ] = value
  
  { indexData..., plainData }

export { extendModel, wrap, unwrap }