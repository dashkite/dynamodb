import * as combinators from "./combinators"
import { extendModel, buildKey, buildItem, buildQuery } from "./helpers"
 
# Wraps the Sundog DynamoDB key-value store model to handle edges.
Edge = (basic) ->
  (model) ->
    client = basic extendModel model

    get: (context) -> client.get buildKey context
    put: (context) -> client.put buildItem context
    delete: (context) -> client.delete buildKey context
    list: (context) -> client.query buildQuery context
    combinators: combinators

export default Edge

  buildExpressions = protect (context) ->
    {vertex, edge, direction, sort} = context
    unless vertex && direction && vertex && sort
      throw new Error "unable to build query expression without direction, vertex, and sort combinators."

    if sort == "value" && direction == "out"
      context.index = false
      context.keyExpression = "origin = #{qv to.S vertex}"
      context.projectionExpression = "typeTarget, created, stash"

    else if sort == "value" && direction == "in"
      context.index = "InEdgesByValue"
      context.keyExpression = "target = #{qv to.S vertex}"
      context.projectionExpression = "typeOrigin, created, stash"

    else if sort == "time" && direction == "out"
      throw new Error "time sorting requires edge combinator" unless edge
      context.index = "OutEdgesByTime"
      context.keyExpression = "typeOrigin = #{qv to.S "#{edge}:#{vertex}"}"
      context.projectionExpression = "target, created, stash"

    else if sort == "time" && direction == "in"
      throw new Error "time sorting requires edge combinator" unless edge
      context.index = "InEdgesByTime"
      context.keyExpression = "typeTarget = #{qv to.S "#{edge}:#{vertex}"}"
      context.projectionExpression = "origin, created, stash"

    else
      console.error context
      throw new Error "unable to produce key and projection expressions."

    context

  applyRange = protect (context) ->
    {sort, direction, beginsWith, edge, range} = context

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

    context

  compileOptions = protect (context) ->
    context.options =
      ProjectionExpression: context.projectionExpression
      ScanIndexForward: context.ascending
      Limit: context.limit
      ExclusiveStartKey: context.startKey

    context

  runQuery = protect (context) ->
    {index, keyExpression, options} = context

    if index
      {Items, LastEvaluatedKey} =
        await m.queryIndex index, keyExpression, null, options
    else
      {Items, LastEvaluatedKey} =
      await m.queryTable keyExpression, null, options

    context.results = parse Items
    context.next = LastEvaluatedKey if context.returnNext
    context


  query = (fx) ->
    do pipe [
      -> {}
      fx...
      buildExpressions
      applyRange
      compileOptions
      runQuery
    ]



