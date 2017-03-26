# LÖVE Atom

[![Version](https://img.shields.io/badge/Version-2.5.1-blue.svg)](https://github.com/rm-code/love-atom/releases/latest)
[![Atom](https://img.shields.io/badge/Atom-1.15.0-049158.svg)](https://atom.io/)
[![License](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE.md)

A lövely provider for [Atom](https://atom.io/)'s [autocomplete+](https://github.com/atom/autocomplete-plus) package.

## Usage

LÖVE Atom is integrated into Atom's default autocompletion package and will suggest functions based on your input.
![example1](https://raw.githubusercontent.com/rm-code/love-atom/master/screenshots/example1.gif)

Since version `2.5.0` types also start with a variable which can be replaced. You can use `tab` to jump to the arguments afterwards.
![example2](https://raw.githubusercontent.com/rm-code/love-atom/master/screenshots/example2.gif)


_The autocompletion suggestions are generated automatically using the [LÖVE API](https://github.com/love2d-community/love-api) which is following the official [LÖVE wiki](https://love2d.org/wiki/Main_Page)_.

## Installation

You can install the package through Atom's package manager or by running ```apm install love-atom``` in your terminal.

## Dependencies

_The following dependencies will be installed automatically if they are missing:_

- [language-lua](https://github.com/FireZenk/language-lua)
