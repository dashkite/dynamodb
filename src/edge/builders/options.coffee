buildGet = (context) ->
  ConsistentRead: context.isConsistent

buildPut = (context) -> undefined

buildDelete = (context) -> undefined

export { buildGet, buildPut, buildDelete }