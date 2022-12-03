#!/usr/bin/env bash

# Bold
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BPurple='\033[1;35m' # Purple

unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=Mac ;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac

echo ${machine}

echo -e "${BPurple}Initiallizing configuration ..."

verify_jq_linux() {
    if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo -e "${BYellow}Installing jq ..."
        sudo apt install jq
    fi
}

verify_jq_mac_os() {
    if brew list jq &>/dev/null; then
        echo "jq is already installed"
    else
        brew install jq && echo "jq is installed"
    fi
}

verify_jq_windows() {
    echo -e "${BYellow}Looks like that you are using Windows, please install the package with the following command"
    echo -e "${BGreen}choco install jq"
    echo -e "${BGreen}and run this installation again"

    echo -e "${BYellow}if you already have jq installed following the installation"
}

if [ $machine -eq "Linux" ]; then
    verify_jq_windows
fi

if [ $machine -eq "Mac" ]; then
    verify_jq_mac_os
fi

if [ $machine -eq "Cygwin" -o $machine -eq "Cygwin" ]; then
    verify_jq_mac_os
fi

echo -e "${BPurple}Installing following depecies as dev ..."
echo -e "${BGreen}@commitlint/cli @commitlint/config-conventional @rocketseat/eslint-config commitizen eslint husky prettier"
npm i @commitlint/cli @commitlint/config-conventional @rocketseat/eslint-config commitizen eslint husky prettier -D

echo -e "${BPurple}Add script in your package.json ..."
echo "$(jq '.scripts += {"prepare": "husky install"}' package.json)" >package.json
echo "$(jq '.scripts += {"commit": "git-cz"}' package.json)" >package.json
echo "$(jq '.scripts += {"lint": "eslint src --ext .tsx,.ts"}' package.json)" >package.json
echo "$(jq '.scripts += {"lint:fix": "npm run lint -- --fix"}' package.json)" >package.json
echo "$(jq '.["lint-staged"] += { "**/*": "prettier --write --ignore-unknown", "src/**": "npm run lint:fix" }' package.json)" >package.json
echo "$(jq '.config += { "commitizen": {"path": "./node_modules/cz-conventional-changelog" } }' package.json)" >package.json
echo -e "${BGreen}Scripts has been addded!"

echo -e "${BPurple}Add lint config files ..."
echo "module.exports = { extends: ['@commitlint/config-conventional'] }" >commitlint.config.js
echo '{ "extends": ["@rocketseat/eslint-config/react"] }' >.eslintrc.json
echo -e "node_modules\nsrc/**/*.css" >.eslintignore
echo -e "${BGreen}Lint files has been addded!"

echo -e "${BPurple}Initiallizing husky ..."
npm run prepare
npx husky add .husky/pre-commit "npx lint-staged"
npx husky add .husky/commit-msg 'npx commitlint --edit'
echo -e "${BGreen}husky has been configured successfully!"

echo -e "${BYellow}Trying to run command 'git add .' and 'npm run commit' to check configuration"
