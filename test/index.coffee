import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { scalarWrap, setWrap, listWrap, mapWrap } from "./wrap"
import * as basic from "./basic"

do -> 

  print await test "graphite-core", [

    test "wrap / unwrap", [
      test "scalar", scalarWrap
      test "set", setWrap
      test "list", listWrap
      test "map", mapWrap 
    ]

    test "basic", [
      test
        description: "get + put + delete"
        wait: false
        basic.GPD

      test
        description: "query builder"
        wait: false
        basic.queryBuilder

      test
        description: "table query"
        wait: false
        basic.tableQuery

      test
        description: "index query"
        wait: false
        basic.indexQuery
    ]

  ]

  process.exit if success then 0 else 1