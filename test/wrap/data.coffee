model =
  id: "S"
  age: "N"
  isMember: "BOOL"
  rawData: "B"
  metadata: "JSON"

data =
  id: "123456789"
  age: 30
  isMember: false
  rawData: new Uint8Array [ 1, 2, 3 ]
  metadata:
    foo: "foo"
    bar: 
      foo: "foo"
      bar: "bar"

expected = 
  id: S: "123456789"
  age: N: "30"
  isMember: BOOL: false
  rawData: B: "AQID"
  metadata: S: """{"foo":"foo","bar":{"foo":"foo","bar":"bar"}}"""

export { model, data, expected }