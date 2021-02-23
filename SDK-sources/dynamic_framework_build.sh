#https://stackoverflow.com/questions/35655698/how-to-archive-an-app-that-includes-a-custom-framework/35703033#35703033

# Merge Script

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
TARGET_NAME="OutbrainSDK"
FRAMEWORK_NAME="OutbrainSDK"
SF_WRAPPER_NAME="${FRAMEWORK_NAME}.xcframework"
SF_RELEASE_DIR="${SRCROOT}/Release/"



# If remnants from a previous build exist, delete them.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi

if [ -d "${SRCROOT}/Release" ]; then
rm -rf "${SRCROOT}/Release"
fi

mkdir "${SRCROOT}/Release"

# https://medium.com/@er.mayursharma14/how-to-create-xcframework-855817f854cf

# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild archive -scheme "${TARGET_NAME}" -destination="iOS" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -archivePath "${SRCROOT}/build/Release-iphonesimulator"
xcodebuild archive -scheme "${TARGET_NAME}" -destination="iOS" -sdk iphoneos        SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -archivePath "${SRCROOT}/build/Release-iphoneos"



ls -l "${SRCROOT}/build/"


# XCFramework 
xcodebuild -create-xcframework -allow-internal-distribution \
    -framework "${SRCROOT}/build/Release-iphonesimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -framework "${SRCROOT}/build/Release-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -output "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"

# 8
# Copy the framework back for the Journal app to use
cp -a "${SF_RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework" "${SRCROOT}/../Samples/OutbrainDemo"


# 9
# Delete the most recent build.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi
