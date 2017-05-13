'use babel'

// Spread the LOVE!
let completions, LoveProvider

function loadDeps () {
  if (!LoveProvider) {
    LoveProvider = require('./love-provider')
  }
  if (!completions) {
    completions = require('../data/love-completions.json')
  }
}

export default {
  activate () {
    this.idleCallbacks = new Set()

    let callbackID

    const installLoveAtomDeps = () => {
      this.idleCallbacks.delete(callbackID)

      require('atom-package-deps').install('love-atom')
      loadDeps()
    }

    callbackID = window.requestIdleCallback(installLoveAtomDeps)

    this.idleCallbacks.add(callbackID)

    console.log('Activating LOVE-Provider. What is love!?')
  },

  deactivate () {
    this.idleCallbacks.forEach(id =>
      window.cancelIdleCallback(id)
    )

    this.idleCallbacks.clear()
  },

  provide () {
    loadDeps()

    return new LoveProvider(completions)
  }
}
