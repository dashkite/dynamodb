import { pipe, rtee, curry } from "@dashkite/joy/function"
import { keys, values, get, merge } from "@dashkite/joy/object"
import { first } from "@dashkite/joy/array"
import { isEmpty } from "@dashkite/joy/value"

queryCombinators = ({ wrap }) ->

  # Takes developer-friendly query objects and converts them into the string
  # fields DynamoDB uses as S-expressions.
  finalize = (context) ->
    _expression = ""
    i = j = 0
    _names = {}
    _values = {}

    subName = (name) ->
      if !_names[ name ]?
        sub = "##{i}"
        _names[ name ] = [ sub ]: name
        i++
      else
        sub = first keys get name, _names
      
      sub

    subValue = (value) ->
      sub = ":#{j}"
      _values[ sub ] = first values wrap value
      j++
      sub

    applyPartition = ->
      { partition: { key, value } } = context
      _expression += "#{subName key} = #{subValue [ key ]: value}"

    applySort = ->
      { sort: { key, value, value2, type } } = context
      _expression += " AND "
      object = subValue [ key ]: value
      object2 = [ key ]: value2
      key = subName key

      switch type
        when "eq"
          _expression += "#{key} = #{object}"
        when "lt"
          _expression += "#{key} < #{object}"
        when "lte"
          _expression += "#{key} <= #{object}"
        when "gt"
          _expression += "#{key} > #{object}"
        when "gte"
          _expression += "#{key} >= #{object}"
        when "beginsWith"
          _expression += "begins_with ( #{key}, #{object} ) "
        when "between"
          _expression += "#{key} BETWEEN #{object} AND #{subValue object2}"
        else
          throw new Error "unsupported sort expression [#{type}]"

    applyProjection = ->
      fields = ( subName field for field in context.include )
      context.query.ProjectionExpression = fields.join ","



    if context.partition?
      applyPartition()
      if context.sort?
        applySort()
    
    if context.include? 
      applyProjection() 

    if ! isEmpty _expression
      context.query.KeyConditionExpression = _expression
    
    if ! isEmpty _names
      context.query.ExpressionAttributeNames = merge ( values _names )...
      
    if ! isEmpty _values
      context.query.ExpressionAttributeValues = _values

    context.query
    
  
  build: (fns) -> 
    pipe [
      -> query: {}
      fns...
      finalize
    ]

  fromIndex: curry rtee (name, context) -> 
    context.query.IndexName = name

  startAfter: curry rtee (key, context) ->
    context.query.ExclusiveStartKey = key

  isConsistent: curry rtee (isConsistent, context) ->
    context.query.ConsistentRead = isConsistent

  limit: curry rtee (limit, context) ->
    context.query.Limit = limit

  include: curry rtee (fields, context) ->
    context.include = fields 

  sortDirection: curry rtee (direction, context) ->
    if direction == "ascending"
      context.query.ScanIndexForward = true
    else if direction == "descending"
      context.query.ScanIndexForward = false
    else
      throw new Error "unknown sort direction [ #{direction} ]"

  partitionKey: curry rtee (value, context) ->
    context.partition = value

  sortKey: curry rtee (value, context) ->
    context.sort = value

export default queryCombinators