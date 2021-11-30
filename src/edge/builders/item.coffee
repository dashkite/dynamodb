import { wrap } from "../mapping"
import { buildEdgeNode } from "./helpers"

buildItem = (context) ->
  { origin, edge, target, secondary, stash } = context
  now = new Date().toISOString()    
  created = context.created ? now
  updated = context.updated ? now
  
  if !secondary? 
    secondary = "secondary::created::#{created}"
    stash.secondary = 
      namespace: "secondary"
      type: "created"
      value: created

  {
    origin
    edge
    target
    edgeOrigin: buildEdgeNode stash.edge, stash.origin
    edgeTarget: buildEdgeNode stash.edge, stash.target
    secondary
    created
    updated
    stash
    expiresAt: context.expiresAt
    ( wrap context.plainData )...
  }

export { buildItem }