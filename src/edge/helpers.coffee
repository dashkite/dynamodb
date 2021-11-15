import { curry } from "@dashkite/joy/function"
import { merge, mask } from "@dashkite/joy/object"

extendModel = (model) ->
  _properties = {}
  _properties[ "_#{name}" ] = type for name, type of model.properties
  
  key: ["origin", "typeTarget"]
  types: merge _properties,
    origin: "S"
    target: "S"
    typeTarget: "S"
    typeOrigin: "S"
    secondary: "S"
    created: "S"
    updated: "S"
    stash: "JSON"
    expiresAt: "N"

wrap = curry (model, data) ->
  result = {}
  for name, type of model.properties when name[0] == "_"
    _property = name
    property = _property[1...]
    result[ _property ] = data[ property ]
  result
  
unwrap = curry (model, data) ->
  plainData = {}
  indexData = {}
  for name, type of model.properties
    if name[0] == "_"
      _property = name
      property = _property[1...]
      plainData[ property ] = data[ _property ]
    else
      indexData[ name ] = data[ name ]
  
  { plainData, indexData... }


buildKey = ({ origin, edge, target }) ->
  origin: origin
  typeTarget: "#{edge}::#{target}"

buildItem = curry (wrap, context) ->
  { origin, edge, target } = context
  now = new Date().toISOString()
  created = context.created ? now
  updated = context.updated ? now
  secondary = context.secondary ? type: "created", value: created

  merge ( wrap context.plainData ),
    origin: origin
    target: target
    typeTarget: "#{edge}::#{target}"
    typeOrigin: "#{edge}::#{origin}"
    secondary: secondary
    created: created
    updated: updated
    stash: context.stash
    expiresAt: context.expiresAt



export {
  extendModel
}
    

  