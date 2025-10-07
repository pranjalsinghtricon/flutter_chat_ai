#!/bin/bash

# Function to export environment variables
load_to_env(){
  echo "$1=$2" >> $WORKSPACE/env_vars
  export "$1=$2"
}

  
setup_tool_versions_env_variables() {
  load_to_env "flutter-version" "3.35.1"
  load_to_env "android-cmdline-tools-version" "10406996"
  load_to_env "ruby-version" "3.4.4"
  load_to_env "fastlane-version" "2.228.0"
  load_to_env "amazon-corretto-jdk-version" "17"
  load_to_env "DEVELOPER_DIR" "/Applications/Xcode.app/Contents/Developer"
  load_to_env "sdk-path-suffix" "flutter_sdk"
}

setup_tool_versions_env_variables


