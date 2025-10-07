#!/bin/bash

# This script is used to setup fastlane along with its dependencies such as homebrew, rbenv, ruby, git, android-sdk etc... It is tested to be working for macos

RUBY_VERSION=$1
FASTLANE_VERSION=$2

print_debug_info() {
  echo "print_debug_info function invoked"
  echo "OS_INFO is $(system_profiler SPSoftwareDataType)"
  echo "PATH Variable: $PATH"
  echo "\n"
}

print_postinstall_debug_info() {
  echo "print_postinstall_debug_info function invoked"
  echo "BREW version: $(brew -v)"
  echo "GCC version: $(gcc -v)"
  echo "RBENV version: $(rbenv -v)"
  echo "RBENV ruby list: $(rbenv versions)"
  echo "RUBY version: $(ruby -v)"
  echo "RUBY Path: $(which ruby)"
  echo "GEM version: $(gem -v)"
  echo "GEM Path: $(which gem)"
  echo "GEM env: $(gem env)"
  echo "FASTLANE version: $(fastlane -version)"
  echo "FASTLANE Path: $(which fastlane)"
  echo "PATH Variable: $PATH"
  echo "JAVA Version: $(java -version)"
  echo "\n"
}

load_to_path(){
  echo "PATH=$1:\$PATH" >> $WORKSPACE/env_vars
  export PATH=$PATH:$1
}


prepend_to_path() {
  echo "PATH=$1:\$PATH" >> $WORKSPACE/env_vars
  export PATH=$1:$PATH
  echo "WORKSPACE ENV_VARS UPDATED: $WORKSPACE/env_vars"
  echo "PATH IS: $PATH"
}


load_to_env(){
  echo "$1=$2" >> $WORKSPACE/env_vars
  export "$1=$2"
}


#install_deps is used to install various dependecies for fastlane based on their current installation status
install_deps() {
  print_debug_info

  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    echo "Homebrew Installation Exists, Loading it to PATH"
    load_to_path /opt/homebrew/bin
  fi

  echo "Installing and setting up rbenv, ruby-build and ruby for current folder: ${pwd}"
  brew install rbenv ruby-build  #it will automatically skip if installed
  rbenv install -s $RUBY_VERSION #(-s) will skip if installed
  rbenv local $RUBY_VERSION      #set the local ruby version for this project

  prepend_to_path "$HOME/.rbenv/shims" #rbenv path needs to be prepended to path

  echo "Installing Fastlane if not installed"
  gem install fastlane -v $FASTLANE_VERSION #This will install fastlane and all it's dependencies

  print_postinstall_debug_info
}

install_deps
