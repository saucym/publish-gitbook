#!/bin/sh

git clone https://github.com/saucym/saucym.github.io.git _book

# install the plugins and build the static site
gitbook install && gitbook build

cd _book

# add all files
git add .

# commit
COMMIT_MESSAGE="Update gitbook `date '+%Y-%m-%d %H:%M:%S'`"
git commit -a -m "${COMMIT_MESSAGE}"

# push to the origin
git push
