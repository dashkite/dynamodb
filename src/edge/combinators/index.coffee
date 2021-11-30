import * as h from "./helpers"

combinators = ->
  {
    h...

    beginsWith: h.set "beginsWith"
    created: h.set "created"
    fromIndex: h.set "fromIndex"
    edge: h.setIndex "edge"
    edgeDirection: h.set "edgeDirection"
    expiresAt: h.set "expiresAt"
    isConsistent: h.set "isConistent"
    limit: h.set "limit"
    origin: h.setIndex "origin"
    plainData: h.assign "plainData"
    primary: h.setIndex "primary"
    returnNext: h.set "returnNext"
    secondary: h.setIndex "secondary"
    sortDirection: h.set "sortDirection"
    startAfter: _assign "startAfter"
    stash: h.setStash "manual"
    target: h.setIndex "target"
    updated: h.set "updated"
  }

export default combinators