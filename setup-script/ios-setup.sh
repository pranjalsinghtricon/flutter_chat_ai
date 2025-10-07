#!/bin/bash
# This script is used to setup ios env with dependencies such as keychain, git lfs, cocoapods & distribution & provisioning certificates

: '
ENV Variables - Required:
   K12_BUILD_KEYCHAIN_PASSWORD
   APPSTORE_DEV_DIST_PROV_PROFILE_DATA_B64ENC
'

: '
ENV Variables - Optional:
   DISTRIBUTION_CERT_PVT_KEY_PASSWORD 
   DISTRIBUTION_CERT_PVT_KEY_DATA_B64ENC
   KEYCHAIN_NAME (default: k12-build) - for job isolation in parallel testing
'

DIST_CERT_NAME="Apple Distribution: Tricon Infotech Private Limited"
# Support environment variable for keychain name (for job isolation in parallel testing)
KEYCHAIN_NAME="${KEYCHAIN_NAME:-k12-build}"

print_debug_info(){
   echo "print_debug_info function invoked"
   echo "OS_INFO is $(system_profiler SPSoftwareDataType)"
   echo "PATH Variable: $PATH"
   echo "XCODE_VERSION is $(/usr/bin/xcodebuild -version)"
   echo "\n"
}

# creates a new key chain to setup build related credentials. 
setup_keychain(){
  echo 'Setting up Keychain'
	if ! security list-keychains | grep -q ${KEYCHAIN_NAME}.keychain; then
		echo "No Keychain Found with name: $KEYCHAIN_NAME. Creating a new one"
		security create-keychain -p $K12_BUILD_KEYCHAIN_PASSWORD "$KEYCHAIN_NAME.keychain"
    security list-keychains -d user -s login.keychain "$KEYCHAIN_NAME.keychain"
    security set-keychain-settings "$KEYCHAIN_NAME.keychain"
	fi
}

setup_apple_worldwide_developer_relations_ca_cert(){
   echo 'Setting up apple worldwide developer relations ca'
   security find-certificate
   APPLE_DEVELOPER_CA_CERT_B64_ENC="MIIEUTCCAzmgAwIBAgIQfK9pCiW3Of57m0R6wXjF7jANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzETMBEGA1UEChMKQXBwbGUgSW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxFjAUBgNVBAMTDUFwcGxlIFJvb3QgQ0EwHhcNMjAwMjE5MTgxMzQ3WhcNMzAwMjIwMDAwMDAwWjB1MUQwQgYDVQQDDDtBcHBsZSBXb3JsZHdpZGUgRGV2ZWxvcGVyIFJlbGF0aW9ucyBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTELMAkGA1UECwwCRzMxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2PWJ/KhZC4fHTJEuLVaQ03gdpDDppUjvC0O/LYT7JF1FG+XrWTYSXFRknmxiLbTGl8rMPPbWBpH85QKmHGq0edVny6zpPwcR4YS8Rx1mjjmi6LRJ7TrS4RBgeo6TjMrA2gzAg9Dj+ZHWp4zIwXPirkbRYp2SqJBgN31ols2N4Pyb+ni743uvLRfdW/6AWSN1F7gSwe0b5TTO/iK1nkmw5VW/j4SiPKi6xYaVFuQAyZ8D0MyzOhZ71gVcnetHrg21LYwOaU1A0EtMOwSejSGxrC5DVDDOwYqGlJhL32oNP/77HK6XF8J4CjDgXx9UO0m3JQAaN4LSVpelUkl8YDib7wIDAQABo4HvMIHsMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAUK9BpR5R2Cf70a40uQKb3R01/CF4wRAYIKwYBBQUHAQEEODA2MDQGCCsGAQUFBzABhihodHRwOi8vb2NzcC5hcHBsZS5jb20vb2NzcDAzLWFwcGxlcm9vdGNhMC4GA1UdHwQnMCUwI6AhoB+GHWh0dHA6Ly9jcmwuYXBwbGUuY29tL3Jvb3QuY3JsMB0GA1UdDgQWBBQJ/sAVkPmvZAqSErkmKGMMl+ynsjAOBgNVHQ8BAf8EBAMCAQYwEAYKKoZIhvdjZAYCAQQCBQAwDQYJKoZIhvcNAQELBQADggEBAK1lE+j24IF3RAJHQr5fpTkg6mKp/cWQyXMT1Z6b0KoPjY3L7QHPbChAW8dVJEH4/M/BtSPp3Ozxb8qAHXfCxGFJJWevD8o5Ja3T43rMMygNDi6hV0Bz+uZcrgZRKe3jhQxPYdwyFot30ETKXXIDMUacrptAGvr04NM++i+MZp+XxFRZ79JI9AeZSWBZGcfdlNHAwWx/eCHvDOs7bJmCS1JgOLU5gm3sUjFTvg+RTElJdI+mUcuER04ddSduvfnSXPN/wmwLCTbiZOTCNwMUGdXqapSqqdv+9poIZ4vvK7iqF0mDr8/LvOnP6pVxsLRFoszlh6oKw0E6eVzaUDSdlTs="
   CERT_FILE_NAME="AppleWWDRCAG3.cer"
   echo $APPLE_DEVELOPER_CA_CERT_B64_ENC | base64 -d > $CERT_FILE_NAME
   echo 'Importing CA to keychain'
   security import $CERT_FILE_NAME -k "$KEYCHAIN_NAME.keychain"
   rm -rf $CERT_FILE_NAME
   security find-certificate
}

# creates a new key chain to setup build related credentials. 
setup_distribution_certificate(){
   echo 'Setting up apple distribution certificate'
   temp_key_name="k12-dst-pvt-key-temp.p12"

   echo 'Checking if the certificate is expired and exists'
   # delete cert from keychain if it is expired
   if security find-identity | grep -E "\b${DIST_CERT_NAME}\b.*\bCSSMERR_TP_CERT_EXPIRED\b"; then
      security delete-certificate -c "${DIST_CERT_NAME}"
   fi

   if ! security find-identity $KEYCHAIN_NAME.keychain | grep "${DIST_CERT_NAME}"; then
      echo "Unable to find Distribution Certificate with name: ${DIST_CERT_NAME}. Adding it"
      echo $DISTRIBUTION_CERT_PVT_KEY_DATA_B64ENC | base64 -d > $temp_key_name
      security import $temp_key_name  -k "$KEYCHAIN_NAME.keychain" -P $DISTRIBUTION_CERT_PVT_KEY_PASSWORD -T $(which codesign)
      ls -lah
      rm -f $temp_key_name
      ls -lah | grep $temp_key_name
      if $(ls -lah | grep $temp_key_name); then
         echo "Distribution Private Key is not removed because of some error. Please delete it."
         exit 1
      fi
      echo "Modifying access control to allow codesign to access keychain without password"
   fi
   security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k $K12_BUILD_KEYCHAIN_PASSWORD "$KEYCHAIN_NAME.keychain"
}

setup_provisioning_profile(){
   echo 'Setting up provisioning profile'
   provisioning_profiles_dir="${HOME}/Library/MobileDevice/Provisioning Profiles"
   mkdir -p "${provisioning_profiles_dir}"
   k12_provisioning_profile_name=$(echo $1 | base64 -d | grep UUID -A1 -a | grep -io "[-a-f0-9]\{36\}")
   provisioning_profile_path="${provisioning_profiles_dir}/${k12_provisioning_profile_name}.mobileprovision"
   echo $provisioning_profile_path
   if [[ ! -f $provisioning_profile_path ]]; then 
      echo "K12 Provisioning Profile with name: ${provisioning_profile_path} doesn't exist. Adding it to ${provisioning_profiles_dir} directory"
      echo $1 | base64 -d > "${provisioning_profiles_dir}/${k12_provisioning_profile_name}.mobileprovision"
   fi
}

main(){
  print_debug_info
  setup_keychain
  #setup k12 dev app provisioning profile
  [ ! -z $APPSTORE_DEV_DIST_PROV_PROFILE_DATA_B64ENC ] && setup_provisioning_profile $APPSTORE_DEV_DIST_PROV_PROFILE_DATA_B64ENC
  #setup k12 prod app provisioning profile
  [ ! -z $APPSTORE_PROD_DIST_PROV_PROFILE_DATA_B64ENC ] && setup_provisioning_profile $APPSTORE_PROD_DIST_PROV_PROFILE_DATA_B64ENC
  setup_apple_worldwide_developer_relations_ca_cert
  setup_distribution_certificate  
  
  if ! (pod --version); then 
    echo "Installing CocoaPods"
    brew install cocoapods
    gem install minitest
  fi

  if ! (git lfs version); then 
    echo "Installing Git LFS"
    brew install git-lfs
  fi
  
}

main