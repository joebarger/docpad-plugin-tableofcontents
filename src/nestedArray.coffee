((nestedArray) ->
	newLevel = (parent) ->
		# Special case for level skipping, like when going from h2 to h4 with no interceeding h3.
		if parent.length is 0
			parent.push
				level: parent.level
				text: ""
				id: ""

		last = parent[parent.length - 1]
		last.children = []
		last.children.parent = parent
		last.children.level = parent.level + 1
		last.children

	unflatten = (currLevel, newElement) ->
		currLevel.level ?= newElement.level
		if newElement.level > currLevel.level
			return unflatten(newLevel(currLevel), newElement)
		else if newElement.level < currLevel.level
			return unflatten(currLevel.parent, newElement)
		
		currLevel.push newElement
		currLevel

	nestedArray.fromArray = (arr) ->
		result = []
		arr.reduce unflatten, result
		result

	return
) module.exports