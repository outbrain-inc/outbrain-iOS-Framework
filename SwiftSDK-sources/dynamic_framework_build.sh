# 1
# Set bash script to exit immediately if any commands fail.
set -e
set +u
# Avoid recursively calling this script.
if [[ $SF_MASTER_SCRIPT_RUNNING ]]
then
    exit 0
fi
set -u
export SF_MASTER_SCRIPT_RUNNING=1

# 2
# Setup some constants for use later on.
SRCROOT=`pwd`
BUILD_FOLDER=~/build
TARGET_NAME="OutbrainSDK"
FRAMEWORK_NAME="OutbrainSDK"
SF_WRAPPER_NAME="${FRAMEWORK_NAME}.xcframework"
SF_RELEASE_DIR="${SRCROOT}/Release/"



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

echo "Signing the framework..."
codesign --timestamp -v --sign "iPhone Distribution: OUTBRAIN INCORPORATED" "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"

echo "Verifying the signature..."
codesign -vvv -d "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"

# 8
# Copy the framework back for our sample app to use
cp -a "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework" "${SRCROOT}/.."
cp -a "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework" "${SRCROOT}/../Samples/OutbrainDemo"


# 9
# Delete the most recent build.
if [ -d "${BUILD_FOLDER}" ]; then
rm -rf "${BUILD_FOLDER}"
fi