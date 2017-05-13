'use babel'

// Spread the LOVE!
import LoveProvider from './love-provider'

export default {
  activate () {
    require('atom-package-deps').install('love-atom')

    console.log('Activating LOVE-Provider. What is love!?')
  },

  provide () {
    return new LoveProvider()
  }
}
