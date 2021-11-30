import assert from "@dashkite/assert"
import { prepare, client } from "./helpers"

GPD = ->
  data = await prepare "basic-gpd"
  { origin, typeTarget } = data
  
  # Null Get
  assert.deepEqual undefined, await client.get { origin, typeTarget }
  
  # Put on new item
  assert.deepEqual data, await client.put data

  # Get 
  assert.deepEqual data, await client.get { origin, typeTarget }

  # Put on existing item
  data.created = new Date().toISOString()
  assert.deepEqual data, await client.put data
  assert.deepEqual data, await client.get { origin, typeTarget }

  # Delete on existing item
  assert.deepEqual undefined, await client.delete data
  assert.deepEqual undefined, await client.get { origin, typeTarget }

  # Delete on non-existing item
  assert.deepEqual undefined, await client.delete data

export { GPD }