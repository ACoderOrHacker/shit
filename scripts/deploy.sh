#!/usr/bin/env sh

set -e

npm run docs:build

cd docs/.vitepress/dist
rm -rf .git

git config user.name "ACoderOrHacker"
git config user.email "sgy2788@163.com"

git init
git add -A
git commit -m 'deploy docs'
git branch -m master main

git push -f https://github.com/ACoderOrHacker/pinwin.git main:docs
cd -