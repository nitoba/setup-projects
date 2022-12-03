#!/usr/bin/env bash

# Bold
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BPurple='\033[1;35m' # Purple

echo -e "${BPurple}Initiallizing configuration ..."

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    sudo apt install jq
    echo -e "${BYellow}Installing jq ..."
fi

echo -e "${BPurple}Installing following depecies ..."
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
