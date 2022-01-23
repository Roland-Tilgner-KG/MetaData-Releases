#!/bin/sh
export BIN_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export PRJ_PATH=$(cd ${BIN_PATH}/..; pwd)

export CURRENT_VERSION=$(find ${PRJ_PATH}/downloads -mindepth 1 -maxdepth 1 -type d \( ! -iname ".*" -a ! -iname "current" \) -exec basename {} \; | sort -u | tail -n 1)
echo "CURRENT: ${CURRENT_VERSION}"

cp ${PRJ_PATH}/TEMPLATE.md ${PRJ_PATH}/README.md

if [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i '' "s/{VERSION}/${CURRENT_VERSION}/g" "${PRJ_PATH}/README.md"
else
	sed -i "s/{VERSION}/${CURRENT_VERSION}/g" "${PRJ_PATH}/README.md"
fi

cat "${PRJ_PATH}/README.md"