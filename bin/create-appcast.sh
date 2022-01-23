#!/bin/bash
export BIN_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export PRJ_PATH=$(cd ${BIN_PATH}/..; pwd)
export RUBY_PATH=$(which ruby)

cd ${BIN_PATH}/appcast
bundle install --path vendor/bundle
bundle exec ruby appcaster.rb -p ${PRJ_PATH}/downloads -o ${PRJ_PATH}/appcast.xml
