'use babel'

export default class LoveProvider {
  priority = 20;

  getOptions = async function (request, getPreviousOptions, utils, cache) {
    const previousOptions = getPreviousOptions()

    if (!this.completions) {
      try {
        this.completions = utils.reviveOptions(require('../data/love-completions.json'))
      } catch (ex) {
        console.error(ex)
        return { options: (await previousOptions) }
      }
    }

    return utils.mergeOptionsCached(await previousOptions, this.completions, cache)
  }
}
