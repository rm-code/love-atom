# Love-Atom

[![Version](https://img.shields.io/badge/Version-3.1.7-blue.svg)](https://github.com/rm-code/love-atom/releases/latest)
[![License](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE.md)

Love-Atom adds smart autocompletion for the [LÖVE](https://love2d.org) framework in [Atom](https://atom.io/).

![gif](https://raw.githubusercontent.com/rm-code/love-atom/master/screenshots/anim.gif)

## Usage

Love-Atom adds a custom provider on top of [autocomplete-lua](https://github.com/dapetcu21/atom-autocomplete-lua) and will suggest autocompletion based on your input.

_Love-Atom will provide suggestions for functions with multiple variants._
![example1](https://raw.githubusercontent.com/rm-code/love-atom/master/screenshots/function_variants.png)

_Love-Atom even offers type-aware autocompletion for variables returned by the LÖVE framework._
![example2](https://raw.githubusercontent.com/rm-code/love-atom/master/screenshots/type_completion.png)

_The autocompletion suggestions are generated automatically using the [LÖVE API](https://github.com/love2d-community/love-api) which is following the official [LÖVE wiki](https://love2d.org/wiki/Main_Page)_.

## Installation

You can install the package through Atom's package manager or by running ```apm install love-atom``` in your terminal.

## Dependencies

_The following dependencies will be installed automatically if they are missing:_

- [language-lua](https://github.com/FireZenk/language-lua)
- [autocomplete-lua](https://github.com/dapetcu21/atom-autocomplete-lua)

## Using a custom language package

If you want to use a different language package you can simply remove the `language-lua` dependency from love-atom. Open the love-atom package by heading to your settings and clicking on "View Code":

![view-code](https://raw.githubusercontent.com/rm-code/love-atom/master/screenshots/view-code.png)

Open the `package.json` and look for the `"package-deps"` entry at the bottom.

```json
"package-deps": [
  "language-lua",
  "autocomplete-lua"
]
```

Remove the `"language-lua",` line and save. Atom will no longer try to install the `language-lua` from now on.
