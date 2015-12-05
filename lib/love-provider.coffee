fs = require 'fs'
path = require 'path'

module.exports =
    selector: '.source.lua'
    disableForSelector: '.source.lua .comment, .source.lua .string'

    inclusionPriority: 10
    excludeLowerPriority: true

    getSuggestions: ( { editor, bufferPosition, scopeDescriptor, prefix, activatedManually } ) ->
        if prefix.length is 0
            return []

        suggestions = @findSuggestions( @completions, prefix )
        suggestions

    findSuggestions: ( completions, prefix ) ->
        suggestions = []
        for item in completions
            if @compareStrings( item.displayText, prefix )
                suggestions.push( @buildSuggestion( item ) )

        suggestions

    buildSuggestion: ( item ) ->
        suggestion =
            displayText: item.displayText
            snippet: item.snippet
            type: item.type
        return suggestion

    loadCompletions: ->
        @completions = {}
        fs.readFile path.resolve( __dirname, '..', './snippets/love-completions.json' ), ( error, data ) =>
            @completions = JSON.parse( data ) unless error?
            return

    compareStrings: ( a, b ) ->
        a[0].toLowerCase() is b[0].toLowerCase()
