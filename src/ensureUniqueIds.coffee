module.exports = class EnsureUniqueIds
	constructor: ->
		@_idSet = []

	# Private methods...
	_addId: (id) ->
		@_idSet.push(id.toLowerCase())
	
	_inUse: (id) ->
		@_idSet.indexOf(id.toLowerCase()) isnt -1

	_isLegalId: (id) ->
		id? and id is @_textToId(id)

	_textToId: (text) ->
		text.replace(/^[^a-zA-Z]+/, "").replace(/[^a-zA-Z0-9\.\:\_\-]+/g, "-")

	_makeUnique: (id) ->
		baseId = id + "-"
		i = 1
		id = baseId.concat(i++)  while not @_isUnique(id)
		id

	# Public...
	checkId: (id, text) ->
		id = @_textToId(id)  if id? and not @_isLegalId(id)
		id = @_makeUnique(@_textToId(text))  if not id? or @_inUse(id)
		@_addId(id)
		id
