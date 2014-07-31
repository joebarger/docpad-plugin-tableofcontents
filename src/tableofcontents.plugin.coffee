# Export Plugin
module.exports = (BasePlugin) ->
    # Requires
    cheerio = require('cheerio')
    ensureUniqueIds = require('./ensureUniqueIds.coffee')
    nestedArray = require('./nestedArray.coffee')

    # Define Plugin
    class TableofcontentsPlugin extends BasePlugin
        # Plugin name
        name: 'tableofcontents'

        # Plugin configuration
        config:
            # Which document extentions to search and generate.
            # For now, only html is supported.
            documentExtensions: ["html"]

            # Is a metadata field required?
            requireMetadata: true
            # If true, specify required metadata field. Set this field to true.
            requiredMetadataField: 'toc'

            # Add missing header id tags for ToC links.
            addHeaderIds: true
            # When adding header ids, use this prefix.
            headerIdPrefix: ''
            
            # List of header elements to search.
            headerSelectors: 'h2,h3,h4,h5'

            # Which header level should we start with. 
            rootHeaderLevel: 2

        # Locale
        locale:
            parsingTocHeaders: "Parsing ToC headers: "
            buildingToc: "Building ToC: "


        # Render Before, make sure we have required metadata placeholders
        renderBefore: (opts,next) ->
            # Prepare
            documents = @docpad.getCollection(@config.collectionName or 'documents')
            config = @config
            locale = @locale

            # Cycle through all our documents
            documents.forEach (document) ->
                tableOfContents = document.tableOfContents? or []
                document.set(tableOfContents: tableOfContents)

                tocProcessed = document.tocProcessed? or false
                # document.tocProcessed = tocProcessed
                document.set(tocProcessed: tocProcessed)

                if config.requireMetadata
                    requiredMetadataFieldValue = document[config.requiredMetadataField]? or false
                    document[config.requiredMetadataField] = requiredMetadataFieldValue

            # All done
            return next()


        # Render the document
        renderDocument: (opts,next) ->
            # Prepare
            {extension,templateData,file,content} = opts
            me = @
            docpad = @docpad
            config = @config
            locale = @locale
            document = templateData.document

            # Handle
            if file.type is 'document' and extension in config.documentExtensions and not document.tocProcessed
                if not config.requireMetadata or document[config.requiredMetadataField]
                    document.tocProcessed = true;

                    # Log
                    docpad.log('debug', locale.parsingTocHeaders+document.name)

                    # Create DOM from the file content
                    $ = cheerio.load("#{opts.content}")

                    # Reset Unique ID set for each document
                    if config.addHeaderIds
                        ensureUniqueIds.init()

                    # Get headers, assigning ids if requested
                    headers = $(config.headerSelectors).map(->
                        $me = $(this)

                        _level = +@name.substring(1)
                        _id = $me.attr("id")
                        _text = $me.text().trim()

                        if config.addHeaderIds
                            _newId = ensureUniqueIds.checkId(_id or "", config.headerIdPrefix+_text)
                            if _newId isnt _id
                                $me.attr "id", _newId
                                _id = _newId

                        # Return...
                        level: _level
                        text: _text
                        id: _id
                    ).get()

                    if headers.length is 0
                        return next()

                    # Log
                    docpad.log('debug', locale.buildingToc+document.name)

                    # Build Table of Contents                                
                    toc = nestedArray.fromArray(headers)

                    # Only if we added header ids, update content.
                    if config.addHeaderIds
                        opts.content = $.root().html()

                    # Update docment with contents.
                    document.tableOfContents = toc;

            return next()
