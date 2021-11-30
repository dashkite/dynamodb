# Combine edge and node designations, combining their shards into one suffix.
# We avoid hot partitions as a Partition Key 
# while maintaining proper sort ordering as a Sort Key. 
buildEdgeNode = (edge, node) ->
  result = "#{edge.namespace}::#{edge.type}::#{edge.value}"
  result += "::#{node.namespace}::#{node.type}::#{node.value}"
  result += "::#{edge.shard}" if edge.shard?
  result += "::#{node.shard}" if node.shard?
  result

export { buildEdgeNode }