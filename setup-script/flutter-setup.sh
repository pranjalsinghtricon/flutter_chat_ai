#!/bin/bash

# This script is used to download & setup flutter sdk, android-sdk, Amazon Corretto packages from source. It is tested to be working for macos

# Init required variables
OS_NAME=$(echo "$RUNNER_OS" | awk '{print tolower($0)}')

MANIFEST_BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"
ANDROID_SDK_BASE_URL="https://dl.google.com/android/repository"
AMAZON_JDK_BASE_URL="https://corretto.aws/downloads/latest"

# command line args
FLUTTER_SDK_VERSION=$3
CMDLINE_TOOLS_VERSION=$4
CORRETTO_JDK_VERSION=$5

FLUTTER_SDK_PATH=""
SDK_FILE_EXTENSION=$([ "$OS_NAME" == "macos" ] && echo "zip" || echo "tar.xz")
FLUTTER_SDK_URL="$MANIFEST_BASE_URL/stable/${OS_NAME}/flutter_${OS_NAME}_${FLUTTER_SDK_VERSION}-stable.${SDK_FILE_EXTENSION}"
MAC_PUB_CACHE_DIR="${HOME}/.pub-cache"

ANDROID_SDK_FOLDER="${HOME}/team-mobile/android-sdk"
CMDLINE_TOOLS_DOWNLOAD_FOLDER="${HOME}/team-mobile/android-sdk/cmdline-tools/latest"
CMDLINE_TOOLS_PLATFORM_PREFIX=$([ "$OS_NAME" == "macos" ] && echo "mac" || echo "linux")
CMDLINE_TOOLS_URL="$ANDROID_SDK_BASE_URL/commandlinetools-${CMDLINE_TOOLS_PLATFORM_PREFIX}-${CMDLINE_TOOLS_VERSION}_latest.zip"

JDK_DOWNLOAD_FOLDER="${HOME}/team-mobile/amazon-corretto-jdk"
JDK_DOWNLOAD_URL="${AMAZON_JDK_BASE_URL}/amazon-corretto-${CORRETTO_JDK_VERSION}-x64-${OS_NAME}-jdk.tar.gz"

# This block parses the commandline flags and looks for -f flag
while getopts 'f:' flag; do
  case "${flag}" in
  f) FLUTTER_SDK_PATH=$OPTARG ;;
  ?) exit 1 ;;
  esac
done

# Print the necessary useful info for debugging purposes
print_debug_info(){
   echo "print_debug_info function invoked"
   echo "OS_INFO is $(system_profiler SPSoftwareDataType)"
   echo "FLUTTER_SDK_PATH is $FLUTTER_SDK_PATH"
   echo "MAC_PUB_CACHE_DIR is $MAC_PUB_CACHE_DIR"
   echo "FLUTTER_SDK_VERSION is $FLUTTER_SDK_VERSION"
   echo "CMDLINE_TOOLS_DOWNLOAD_FOLDER is $CMDLINE_TOOLS_DOWNLOAD_FOLDER"
   echo "CMDLINE_TOOLS_VERSION is $CMDLINE_TOOLS_VERSION"
   echo "XCODE_VERSION is $(/usr/bin/xcodebuild -version)"
   echo "\n"
}

load_to_path(){
  echo "PATH=$1:\$PATH" >> $WORKSPACE/env_vars
  export PATH=$PATH:$1
}


load_to_env(){
  echo "$1=$2" >> $WORKSPACE/env_vars
  export "$1=$2"
}


#checks if the sdk version input is valid
check_sdk_version(){
  echo "Checking if given flutter sdk download url: $FLUTTER_SDK_URL is valid"
  status_code=$(curl  --write-out '%{http_code}' --silent --output /dev/null --head $FLUTTER_SDK_URL)
  if [[ $status_code == "200" ]]; then
    echo "Downloading Flutter SDK for the given version: ${FLUTTER_SDK_VERSION} ...."
  else 
    echo "Failed to download Flutter SDK with version: ${FLUTTER_SDK_VERSION}, Received response code: $status_code. Please double check the version input"
    exit 1
  fi
  echo "\n"
}

# download a specific flutter sdk based on os and sdk version input
download_flutter_archive() {
  archive_name=$(basename $1)
  local_download_path="$RUNNER_TEMP/$archive_name"

  echo "Started Downloading flutter sdk from url $FLUTTER_SDK_URL"
  curl --connect-timeout 15 --retry 5 $FLUTTER_SDK_URL >$local_download_path  
  echo "Completed Downloading Flutter SDK"

  echo "Started Extracting Flutter SDK"
  #Create directories and sub-dirs if doesn't exist
  mkdir -p "$2"

  if [[ $archive_name == *zip ]]; then
    unzip -q -o "$local_download_path" -d "$RUNNER_TEMP"
    rm -r "$2"
    mv ${RUNNER_TEMP}/flutter "$2"
  else
    tar xf "$local_download_path" -C "$2" --strip-components=1
  fi
  echo "Completed Extracting Flutter SDK" 
  
  rm $local_download_path
}

setup_flutter_sdk(){
  # Download flutter if the specified version doesnt exist in path, we are suffixing flutter version code in the sdk folder name
  if [[ ! -x "${FLUTTER_SDK_PATH}/bin/flutter" ]]; then
      download_flutter_archive "$FLUTTER_SDK_URL" "$FLUTTER_SDK_PATH"
  else 
      echo "Flutter SDK exists under path ${FLUTTER_SDK_PATH}. So skipping download"
  fi

  # set env variables 
  echo "FLUTTER_ROOT=${FLUTTER_SDK_PATH}" >>$GITHUB_ENV
  echo "PUB_CACHE=${MAC_PUB_CACHE_DIR}" >>$GITHUB_ENV

  # load sdk and pub cache folder into system path
  load_to_path "${FLUTTER_SDK_PATH}/bin"
  load_to_path "${FLUTTER_SDK_PATH}/bin/cache/dart-sdk/bin"
  load_to_path "${MAC_PUB_CACHE_DIR}/bin"
}

# this function is used to setup android sdk for flutter. It download commandline tools initially and uses it to fetch other dependecies such as platform-tools, build-tools, platforms etc.. and accept their licenses
setup_android_sdk(){
  # check if sdkmanager is available and licenses are accepted
  if [[ -f "${CMDLINE_TOOLS_DOWNLOAD_FOLDER}/bin/sdkmanager" && -f "${ANDROID_SDK_FOLDER}/licenses/google-gdk-license" ]]; then
      echo "Android SDK is already setup"
      return
  fi

  local_download_path="${CMDLINE_TOOLS_DOWNLOAD_FOLDER}/cmd-line-tools.zip"
  mkdir -p "$CMDLINE_TOOLS_DOWNLOAD_FOLDER"

  echo "Started Downloading Android Command Line Tools from url $CMDLINE_TOOLS_URL"
  curl --connect-timeout 15 --retry 5 $CMDLINE_TOOLS_URL -o $local_download_path
  echo "Completed Downloading Android Command Line Tools"

  echo "Started Extracting Android Command Line Tools"
  unzip -q -o "$local_download_path" -d "$CMDLINE_TOOLS_DOWNLOAD_FOLDER"
  echo "Completed Extracting Android Command Line Tools"

  mv "${CMDLINE_TOOLS_DOWNLOAD_FOLDER}/cmdline-tools"/* "$CMDLINE_TOOLS_DOWNLOAD_FOLDER"
  
  # clean unnecessary files & folders
  rm -rf "$local_download_path" "${CMDLINE_TOOLS_DOWNLOAD_FOLDER}/cmdline-tools"

  # fetch dependencies required to build project
  echo Y | $CMDLINE_TOOLS_DOWNLOAD_FOLDER/bin/sdkmanager "platform-tools" "platforms;android-32" "build-tools;32.0.0"
  # set android-sdk path for flutter
  flutter config --android-sdk "$ANDROID_SDK_FOLDER"
  # weird hack to accept android-sdk licenses as yes command is going into an infinite loop. printf prints 10 times Y assuming less than 10 license prompts
  printf 'Y\n%.0s' {1..10} | flutter doctor --android-licenses
  
  echo "Running Flutter Doctor"
  flutter doctor
}

# this functions validates and then downloads the Amazon Corretto JDK version
setup_jdk(){
  load_to_env "JAVA_HOME" "${JDK_DOWNLOAD_FOLDER}/amazon-corretto-${CORRETTO_JDK_VERSION}.jdk/Contents/Home/" 

  if [[ -f "${JDK_DOWNLOAD_FOLDER}/amazon-corretto-${CORRETTO_JDK_VERSION}.jdk/Contents/Home/bin/java" ]]; then
      echo "Amazon Corretto JDK ${CORRETTO_JDK_VERSION} is already downloaded & setup, so skipping it.."
      return
  fi

  echo "Checking if given JDK Version URL: $JDK_DOWNLOAD_URL is valid"
  status_code=$(curl -L --write-out '%{http_code}' --silent --output /dev/null --head $JDK_DOWNLOAD_URL)

  if [[ $status_code != "200" ]]; then
    echo "Invalid URL or Version given for Amazon Corretto JDK. Please try again..."
    exit 1
  fi

  local_download_path="${JDK_DOWNLOAD_FOLDER}/amazon-corretto-${CORRETTO_JDK_VERSION}.tar.gz"
  mkdir -p "${JDK_DOWNLOAD_FOLDER}"

  echo "Started Downloading Amazon Corretto JDK from url $JDK_DOWNLOAD_URL"
  curl -L --connect-timeout 15 --retry 5 $JDK_DOWNLOAD_URL -o $local_download_path
  echo "Completed Downloading Amazon Corretto JDK"

  echo "Started Extracting Amazon Corretto JDK"
  tar -xf "$local_download_path" -C ${JDK_DOWNLOAD_FOLDER}
  echo "Completed Extracting Amazon Corretto JDK"
  
  # clean unnecessary files
  rm -rf "$local_download_path"
  
  echo "Running Java Version"
  java -version
}

# contains all the init logic
main() {
  print_debug_info
  # setup jdk only if CORRETTO_JDK_VERSION is defined. JDK is not required for few build runs such as pr to master etc..
  if [ ! -z $CORRETTO_JDK_VERSION ]; then
    setup_jdk
  fi
  check_sdk_version
  setup_flutter_sdk
  setup_android_sdk
}

main;