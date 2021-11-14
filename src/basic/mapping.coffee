import { isObject } from "@dashkite/joy/type"
import { unwrap as _unwrap, wrap as _wrap } from "../mapping"

buildMapping = (model) ->
  mapping = 
    wrap: _wrap model.types
    unwrap: _unwrap model.types
    mapKey: (data) ->
      # Map the "basic" model to DynamoDB's partition + sort indexing model.
      [ partition, sort ] = model.key

      if sort?
        # If there is a sort key, data must be provided as an object.
        key =
          [ partition ]: data[ partition ]
          [ sort ]: data[ sort ]

      else
        # With no sort key, we accept flat values as well as objects.
        if isObject data
          key = [ partition ]: data[ partition ]
        else
          key = [ partition ]: data

      mapping.wrap key
  
  mapping

export { buildMapping }