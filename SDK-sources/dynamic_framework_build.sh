#https://stackoverflow.com/questions/35655698/how-to-archive-an-app-that-includes-a-custom-framework/35703033#35703033

# Merge Script

# 1
# Set bash script to exit immediately if any commands fail.
set -e

# 2
# Setup some constants for use later on.
SRCROOT=`pwd`
BUILD_FOLDER=~/build
TARGET_NAME="OutbrainSDK"
FRAMEWORK_NAME="OutbrainSDK"
SF_WRAPPER_NAME="${FRAMEWORK_NAME}.xcframework"
SF_RELEASE_DIR="${SRCROOT}/Release/"


# # Initialize a variable to store the skip signing flag.
skip_signing=false

# Loop through the command-line arguments.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-signing)
      skip_signing=true
      shift # Consume the flag argument.
      ;;
    *)
      # Handle other arguments if needed.
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# If remnants from a previous build exist, delete them.
if [ -d "${BUILD_FOLDER}" ]; then
rm -rf "${BUILD_FOLDER}"
mkdir "${BUILD_FOLDER}"
fi

if [ -d "${SRCROOT}/Release" ]; then
rm -rf "${SRCROOT}/Release"
fi

mkdir "${SRCROOT}/Release"

# https://medium.com/@er.mayursharma14/how-to-create-xcframework-855817f854cf

# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild archive -scheme "${TARGET_NAME}" -destination 'generic/platform=iOS' SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -archivePath "${BUILD_FOLDER}/Release-iphonesimulator"
xcodebuild archive -scheme "${TARGET_NAME}" -destination 'generic/platform=iOS Simulator' SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -archivePath "${BUILD_FOLDER}/Release-iphoneos"

ls -l "${BUILD_FOLDER}"

echo "**********************************************"
echo "xcodebuild -create-xcframework ..."
echo "**********************************************"
xcodebuild -create-xcframework -allow-internal-distribution \
    -framework "${BUILD_FOLDER}/Release-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${BUILD_FOLDER}/Release-iphonesimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"

ls -l "${SF_RELEASE_DIR}"

if [ "$skip_signing" = true ]; then
    echo "Skipping signing."
else
    echo "Signing the framework..."
    codesign --timestamp -v --sign "iPhone Distribution: OUTBRAIN INCORPORATED" "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"

    echo "Verifying the signature..."
    codesign -vvv -d "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"
fi



# # 8
# # Copy the framework back for the Journal app to use
cp -a "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework" "${SRCROOT}/../Samples/OutbrainDemo"


# # 9
# # Delete the most recent build.
if [ -d "${BUILD_FOLDER}" ]; then
rm -rf "${BUILD_FOLDER}"
fi