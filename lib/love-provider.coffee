fs = require 'fs'
path = require 'path'
{score} = require 'fuzzaldrin'

module.exports =
    selector: '.source.lua, .source.moon'
    disableForSelector: '.source.lua .comment, .source.lua .string, .source.moon .comment, .source.moon .string'

    getSuggestions: ( { editor, bufferPosition } ) ->
        prefix = @getPrefix(editor, bufferPosition)
        if prefix.length is 0
            return []
        @findSuggestions( @completions, prefix )

    getPrefix: (editor, bufferPosition) ->
        regex = /[a-zA-Z\_\-\.\:]+$/
        line = editor.getTextInRange( [[bufferPosition.row, 0], bufferPosition] )
        line.match(regex)?[0] or ''

    findSuggestions: ( completions, prefix ) ->
        suggestions = []
        for item in completions
            # Use fuzzaldrin to score suggestions
            if score( item.displayText, prefix ) > 0.1
                suggestions.push( @buildSuggestion( item, prefix ) )
        suggestions

    buildSuggestion: ( item, prefix ) ->
        suggestion =
            displayText: item.displayText
            snippet: item.snippet
            type: item.type
            description: item.description
            descriptionMoreURL: item.descriptionMoreURL
            replacementPrefix: prefix

    loadCompletions: ->
        @completions = {}
        fs.readFile path.resolve( __dirname, '..', './data/love-completions.json' ), ( error, data ) =>
            @completions = JSON.parse( data ) unless error?
            return
