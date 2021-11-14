import { DynamoDB } from "@aws-sdk/client-dynamodb"
import buildMetal from "./metal"
import buildBasic from "./basic"

graphiteCore = (options) ->
  { table, aws } = options
  unless table? then throw new Error "DynamoDB table must be specified."

  context =
    client: new DynamoDB aws 
    table: table

  metal = buildMetal context
  basic = buildBasic metal, context

  { metal, basic }

export default graphiteCore
