# Spread the LOVE!
loveprovider = require './love-provider'

module.exports =
    activate: ->
        require( 'atom-package-deps' ).install()

        console.log( "Activate LOVE-Provider. Baby don't hurt me!" )
        loveprovider.loadCompletions()

     provide: ->
        loveprovider
