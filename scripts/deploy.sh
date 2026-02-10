#!/usr/bin/env sh

set -e

# Check for npx
npx --version
if [$? -ne 0]; then
    echo "error: npx not found"
    exit 1
fi

npx vitepress build

cd docs/.vitepress/dist
rm -rf .git

git config user.name "ACoderOrHacker"
git config user.email "sgy2788@163.com"

git init
git add -A
git commit -m 'deploy docs'
git branch -m master main

git push -f https://github.com/ACoderOrHacker/shit.git main:docs
cd -