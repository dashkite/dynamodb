import { buildEdgeNode } from "./helpers"

buildKey = ({ origin, stash }) -> 
  origin: origin 
  edgeTarget: buildEdgeNode stash.edge, stash.target

buildFetch = ({ fromIndex, origin, target, stash }) ->
  switch fromIndex
    when "OutByPrimary"
      origin: origin 
      edgeTarget: buildEdgeNode stash.edge, stash.target
    when "InByPrimary"
      target: target
      edgeOrigin: buildEdgeNode stash.edge, stash.origin
    when "OutBySecondary"
      origin: origin
      edgeSecondary: buildEdgeNode stash.edge, stash.secondary
    when "InBySecondary"
      target: target
      edgeSecondary: buildEdgeNode stash.edge, stash.secondary
    else
      throw new Error "fromIndex: unknown index #{fromIndex}"

export { buildKey, buildFetch }