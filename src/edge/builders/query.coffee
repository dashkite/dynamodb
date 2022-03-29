# TODO: Validation to ensure vertex, edge, sort, and direction.
applyIndexTypes = (q, context) ->
  { primary } = context

  switch fromIndex
    when "OutByPrimary"
      [ q.partitionKey key: "origin", value: primary ]
    when "InByPrimary"
      [ q.partitionKey key: "target", value: primary ]
    when "OutBySecondary"
      [ q.partitionKey key: "origin", value: primary ]
    when "InBySecondary"
      target: target
      edgeSecondary: buildEdgeNode stash.edge, stash.secondary
    else
      throw new Error "fromIndex: unknown index #{fromIndex}"

  if ( sort == "primary" ) && ( direction == "out" )
    [
      q.partitionKey key: "origin", value: vertex
      q.include [ "typeTarget", "secondary", "stash" ]
    ]

  else if ( sort == "primary" ) && ( direction == "in" )
    [
      q.fromIndex "InByPrimary"
      q.partitionKey key: "target", value: vertex
      q.include [ "typeOrigin", "secondary", "stash" ]
    ]

  else if ( sort == "secondary" ) && ( direction == "out" )
    [
      q.fromIndex "OutBySecondary"
      q.partitionKey key: "typeOrigin", value: "#{edge}::#{vertex}"
      q.include [ "target", "secondary", "stash" ]
    ]

  else if ( sort == "secondary" ) && ( direction == "in" )
    [
      q.fromIndex "InBySecondary"
      q.partitionKey key: "typeTarget", value: "#{edge}::#{vertex}"
      q.include [ "origin", "secondary", "stash" ]
    ]    

  else
    throw new Error "Cannot build partition key and projection expressions." 


 applySortKey = (q, context) ->
  { sort, direction, beginsWith, edge, range } = context


  if ( sort == "primary" ) && ( direction == "out" )
    key = "typeTarget"

  else if ( sort == "primary" ) && ( direction == "in" )
    key = "typeOrigin"

  else if sort == "secondary" 
    key = "secondary"

  else 
    throw new Error "Cannot build sort key expression." 


  if beginsWith? && range?
    throw new Error "Cannot declare beginsWith with range."

  else if beginsWith?
    type = "beginsWith"
    value = beginsWith

  else if range?
    if range.before?
      type = "lt"
      value = range.before
    
    else if range.after?
      type = "gt"
      value = range.after

    else if range.equal?
      type = "eq"
      value = range.equal

    else if range.between?
      type = "between"
      value = range.between[ 0 ]
      value2 = range.between[ 1 ]

    else if range.inclusiveBefore? && range.inclusiveAfter?
      type = "between"
      value = range.inclusiveAfter
      value2 = range.inclusiveBefore
    
    else if range.inclusiveBefore?
      type = "lte"
      value = range.inclusiveBefore

    else if range.inclusiveAfter?
      type = "gte"
      value = range.inclusiveAfter


  if !value? || ( value == "" )
    return []
  else
    [ q.sortKey { key, type, value, value2 } ]
    
  
  if sort == "time"
    field = "created"
    needsPrefix = false
  else if sort == "value" && direction == "out"
    field = "typeTarget"
    needsPrefix = if edge then true else false
  else if sort == "value" && direction == "in"
    field = "typeOrigin"
    needsPrefix = if edge then true else false
  else
    console.error context
    throw new Error "unknown sort type"

  # Special casing for value sorting. Time sorting auto-includes edge in key
  if sort == "value"
    if edge && !beginsWith && !range?.before && !range?.after
      context.keyExpression +=
        " AND (begins_with (#{field}, #{qv to.S edge}))"

  if beginsWith
    beginsWith = "#{edge}:#{beginsWith}" if needsPrefix
    context.keyExpression +=
      " AND (begins_with (#{field}, #{qv to.S beginsWith}))"

  if range?.before
    before = if needsPrefix then "#{edge}:#{range.before}" else range.before
    context.keyExpression += " AND (#{field} < #{qv to.S before})"
  if range?.after
    after = if needsPrefix then "#{edge}:#{range.after}" else range.after
    context.keyExpression += " AND (#{field} > #{qv to.S after})"

  

buildQuery = (basic, context) ->
  q = basic.queryCombinators

  do q.build [
    q.startAfter context.startAfter
    q.isConsistent context.isConsistent
    q.limit context.limit
    q.sortDirection context.sortDirection
    q.include [ "stash" ]
    ( applyIndexTypes q, context )...
    ( applySortKey q, context )...
  ]

export { buildQuery }

# h...

# against: h.set "against"
# beginsWith: h.set "beginsWith"
# created: h.set "created"
# edge: h.setIndex "edge"
# edgeDirection: h.set "edgeDirection"
# expiresAt: h.set "expiresAt"
# # isConsistent: h.set "isConistent"
# # limit: h.set "limit"
# origin: h.setIndex "origin"
# plainData: h.assign "plainData"
# # primary: h.setIndex "primary"
# # returnNext: h.set "returnNext"
# # secondary: h.setIndex "secondary"
# # sortDirection: h.set "sortDirection"
# # startAfter: _assign "startAfter"
# # stash: h.setStash "manual"
# # target: h.setIndex "target"
# updated: h.set "updated"