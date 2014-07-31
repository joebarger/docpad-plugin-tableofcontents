((ensureUniqueIds) ->
  _idSet = []
  _generateId = (text) ->
    id = text.replace(/[^a-zA-Z0-9\.\:\_\-]+/g, "-").replace(/^[^a-zA-Z]/, "")
    i = 0
    newId = id
    newId = id.concat(i++)  while _idSet.indexOf(newId) isnt -1
    newId

  ensureUniqueIds.checkId = (id, text) ->
    id = _generateId(text)  if not id or _idSet.indexOf(id) isnt -1
    _idSet.push id
    id

  ensureUniqueIds.init = ->
    _idSet = []
    this

  return
) module.exports
