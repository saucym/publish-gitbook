#!/bin/sh -l

print_info(){
  echo "\033[32mINFO \033[0m $@" > /dev/stderr
}

print_error(){
  echo "\033[31mERROR\033[0m \a $@" > /dev/stderr
}

PUBLISHER_REPO=""
# setup publisher
if [ -n "${INPUT_PERSONAL_TOKEN}" ]; then
    print_info "using provided PERSONAL_TOKEN"
    PUBLISHER_REPO="https://x-access-token:${INPUT_PERSONAL_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
elif [ -n "${INPUT_GITHUB_TOKEN}" ]; then
    print_info "using automatic GITHUB_TOKEN"
    PUBLISHER_REPO="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
else
    print_error "no PERSONAL_TOKEN or GITHUB_TOKEN found, you can provide one in your workflow YAML"
    exit 1
fi

# config git
git config --local user.name "${GITHUB_ACTOR}"
git config --local user.email "${GITHUB_ACTOR}@users.noreply.github.com"

# install gitbook
print_info "installing gitbook-cli"
npm install gitbook-cli  -g

print_info "installing gitbook plugins"
gitbook --version
gitbook install

rm -r _book
rm -r ${GITHUB_ACTOR}.github.io.git

git clone https://github.com/${GITHUB_ACTOR}/${GITHUB_ACTOR}.github.io.git

pwd

# build gitbook
print_info "buildling gitbook"
gitbook build

cp -R _book/. ${GITHUB_ACTOR}.github.io/

echo copy finish

cd ${GITHUB_ACTOR}.github.io

rm -r .github

git add .

git remote -v

git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git config --global user.name "${GITHUB_ACTOR}"

# commit
COMMIT_MESSAGE="Update gitbook `date '+%Y-%m-%d %H:%M:%S'`"
git commit -a -m "${COMMIT_MESSAGE}"

echo remote set-url
git remote set-url origin https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_ACTOR}/${GITHUB_ACTOR}.github.io.git

echo begin push

git push
