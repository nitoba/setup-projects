#!/usr/bin/env bash

# Bold
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BPurple='\033[1;35m' # Purple

verify_jq_linux() {
    if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo -e "${BYellow}Installing jq ..."
        sudo apt-get install jq -y
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

verify_os_is_running() {
    # Verify that system os is running script
    unameOut="$(uname -s)"
    case "${unameOut}" in
    Linux*) verify_jq_linux ;;
    Darwin*) verify_jq_mac_os ;;
    CYGWIN*) verify_jq_windows ;;
    MINGW*) verify_jq_windows ;;
    *) echo -e "${BRed}UNKNOWN:${unameOut}" && exit 1 ;;
    esac
}

verify_package_json_exists() {
    if [ -f "package.json" ]; then
        echo -e "${BGreen}This is a valid Node project"
    else
        echo -e "${BRed}package.json does not found, please run this script in the root of your Node project"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${BPurple}Installing following depecies as dev ..."
    echo -e "${BGreen}@commitlint/cli @commitlint/config-conventional @rocketseat/eslint-config commitizen eslint husky prettier"
    npm i @commitlint/cli @commitlint/config-conventional @rocketseat/eslint-config commitizen eslint husky prettier -D
}

update_package_json() {
    echo -e "${BPurple}Adding script in your package.json ..."
    echo "$(jq '.scripts += {"prepare": "husky install"}' package.json)" >package.json
    echo "$(jq '.scripts += {"commit": "git-cz"}' package.json)" >package.json
    echo "$(jq '.scripts += {"lint": "eslint src --ext .tsx,.ts"}' package.json)" >package.json
    echo "$(jq '.scripts += {"lint:fix": "npm run lint -- --fix"}' package.json)" >package.json
    echo "$(jq '.["lint-staged"] += { "**/*": "prettier --write --ignore-unknown", "src/**": "npm run lint:fix" }' package.json)" >package.json
    echo "$(jq '.config += { "commitizen": {"path": "./node_modules/cz-conventional-changelog" } }' package.json)" >package.json
    echo -e "${BGreen}Scripts has been addded!"
}

add_lint_files() {
    echo -e "${BPurple}Add lint config files ..."
    echo "module.exports = { extends: ['@commitlint/config-conventional'] }" >commitlint.config.js
    echo '{ "extends": ["@rocketseat/eslint-config/react"] }' >.eslintrc.json
    echo -e "node_modules\nsrc/**/*.css" >.eslintignore
    echo -e '{
    "arrowParens": "always",
    "bracketSpacing": true,
    "htmlWhitespaceSensitivity": "ignore",
    "insertPragma": false,
    "jsxSingleQuote": false,
    "printWidth": 80,
    "proseWrap": "always",
    "quoteProps": "as-needed",
    "requirePragma": false,
    "semi": false,
    "singleQuote": true,
    "tabWidth": 2,
    "trailingComma": "all",
    "useTabs": false,
    "vueIndentScriptAndStyle": false,
    "embeddedLanguageFormatting": "off",
    "endOfLine": "auto"
}'> .prettierrc.json
    echo -e 'node_modules\nbuild\ndist'>.prettierignore
    echo -e "${BGreen}Lint files has been addded!"
}

setup_husky() {
    echo -e "${BPurple}Initiallizing husky ..."
    npm run prepare
    npx husky add .husky/pre-commit "npx lint-staged"
    npx husky add .husky/commit-msg 'npx commitlint --edit'
    echo -e "${BGreen}husky has been configured successfully!"
}

echo -e "${BPurple}Initiallizing configuration ..."

verify_os_is_running
verify_package_json_exists
install_dependencies
update_package_json
add_lint_files
setup_husky

echo -e "${BYellow}Trying to run command 'git add .' and 'npm run commit' to check configuration"
