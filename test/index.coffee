import { test as _test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { scalarWrap, setWrap, listWrap, mapWrap } from "./wrap"
import * as basic from "./basic"
import * as edge from "./edge"

test = (name, x) ->
  if Array.isArray x
    _test name, x
  else
    _test
      description: name
      wait: false
      x

do -> 

  print await test "graphite-core", [

    # test "wrap / unwrap", [
    #   test "scalar", scalarWrap
    #   test "set", setWrap
    #   test "list", listWrap
    #   test "map", mapWrap 
    # ]

    # test "basic", [
    #   test "get + put + delete", basic.GPD
    #   test "query builder", basic.builder
    #   test "table query", basic.table
    #   test "index query", basic.GSI
    #   test "empty partition key query", basic.empty
    # ]

    test "edge", [
      test "build context", edge.build.context
      # test "build key", edge.build.key
      # test "build item", edge.build.item
      # test "build query", edge.build.query
      # test "get + put + delete", edge.GPD
      # test "query primary out", edge.query.primaryOut
      # test "query primary in", edge.query.primaryIn
      # test "query secondary out", edge.query.secondaryOut
      # test "query secondary in", edge.query.seondaryIn
    ]

  ]

  process.exit if success then 0 else 1