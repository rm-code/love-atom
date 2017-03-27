#!/bin/bash
## Use a shallow clone

git clone --depth=1 https://github.com/rm-code/love-api api

## Create definitions
lua json-generator.lua
mv love-completions.json ../data/love-completions.json
rm -rf api

## Commit and push
# Stop if no version flag is provided.
if [[ $1 == "push" ]] ; then
    cd ..
    git add .
    git commit -m "Update love-completions.json"
    git push
fi
