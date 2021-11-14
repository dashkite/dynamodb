import assert from "@dashkite/assert"
import { wrap, unwrap } from "../../src/mapping"
import { model, data, expected } from "./data"

scalarWrap = ->
  wrapped = wrap model, data
  assert.deepEqual expected, wrapped
  assert.deepEqual data, unwrap model, wrapped

listWrap = ->
  _model = {
    model...
    list: "L"
  }

  _data = list: [ data, data, data ]
  _expected = list: L: [ expected, expected, expected ]

  wrapped = wrap _model, _data
  assert.deepEqual _expected, wrapped
  assert.deepEqual _data, unwrap _model, wrapped

mapWrap = ->
  _model = {
    model...
    map: "M"
  }

  _data = map: data
  _expected = map: M: expected

  wrapped = wrap _model, _data
  assert.deepEqual _expected, wrapped
  assert.deepEqual _data, unwrap _model, wrapped

setWrap = ->
  _model =
    a: "SS"
    b: "NS"
    c: "BS"
  
  _data =
    a: new Set [ "a", "b", "c" ]
    b: [ 1, 2, 3 ]
    c: [ 
      new Uint8Array [ 1, 2, 3 ]
      new Uint8Array [ 4, 5, 6 ]
      new Uint8Array [ 7, 8, 9 ] 
    ]

  _expected =
    a: SS: [ "a", "b", "c" ]
    b: NS: [ "1", "2", "3" ]
    c: BS: [ "AQID", "BAUG", "BwgJ" ]

  wrapped = wrap _model, _data
  assert.deepEqual _expected, wrapped

  output = unwrap _model, wrapped

  # Deep equal checks on Set requires elements that are comparable via Object.is
  # Also confirm unwrap always produces Sets.
  _data.b = new Set _data.b
  output.c = Array.from output.c
  assert.deepEqual _data, output

export { scalarWrap, setWrap, listWrap, mapWrap }