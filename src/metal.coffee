metal = (context) ->
  { table: TableName, client: _ } = context

  get: (Key, options) -> _.getItem { TableName, Key, options... }
  put: (Item, options) -> _.putItem { TableName, Item, options... }
  update: (Key, options) -> _.updateItem { TableName, Key, options... }  
  delete: (Key, options) -> _.deleteItem { TableName, Key, options... }
  query: (options) -> _.query { TableName, options... } 
  scan: (options) -> _.scan { TableName, options... } 

export default metal