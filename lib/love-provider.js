'use babel'

export default class LoveProvider {
  priority = 20;

  constructor (completions) {
    this.completions = completions
  };

  getOptions = async function (request, getPreviousOptions, utils, cache) {
    const previousOptions = getPreviousOptions()

    if (!this.revived) {
      try {
        this.revived = utils.reviveOptions(this.completions)
      } catch (ex) {
        console.error(ex)
        return { options: (await previousOptions) }
      }
    }

    return utils.mergeOptionsCached(await previousOptions, this.completions, cache)
  }
}
