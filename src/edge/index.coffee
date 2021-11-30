import combinators from "./combinators"
import { extendModel, unwrap } from "./mapping"
import { 
  buildKey, buildFetch, buildItem, buildQuery 
  buildGet, buildPut, buildDelete
} from "./builders"
 
Edge = (basic) ->
  (model) ->
    client = basic extendModel model

    get: (context) -> 
      item = await client.get ( buildFetch context ), ( buildGet context )
      if item? then unwrap item else undefined
    
    put: (context) -> 
      unwrap await client.put ( buildItem context ), ( buildPut context )
    
    delete: (context) -> 
      client.delete ( buildKey context ), ( buildDelete context )
    
    list: (context) ->
      query = buildQuery client, context
      { results, next } = await client.query query
      _results = []
      _results.push unwrap result for result in results

      if context.returnNext
        results: _results, next: next
      else
        _results
        
    combinators: combinators()
    buildBasicKey: buildKey
    buildBasicFetch: buildFetch
    buildBasicItem: buildItem 
    buildBasicQuery: buildQuery

export default Edge