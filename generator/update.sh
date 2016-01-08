#!/bin/bash
rm -rf api
git clone https://github.com/rm-code/love-api api
lua json-generator.lua
mv love-completions.json ../data/love-completions.json
rm -rf api
