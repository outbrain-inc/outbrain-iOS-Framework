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
SF_WRAPPER_NAME="${FRAMEWORK_NAME}.framework"
SF_RELEASE_DIR="${SRCROOT}/Release/"

if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]
then
    SF_SDK_PLATFORM=${BASH_REMATCH[1]}
else
    echo "Could not find platform name from SDK_NAME: $SDK_NAME"
    exit 1
fi

if [[ "$SF_SDK_PLATFORM" = "iphoneos" ]]
then
    SF_OTHER_PLATFORM=iphonesimulator
else
    SF_OTHER_PLATFORM=iphoneos
fi

if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)$SF_SDK_PLATFORM$ ]]
then
    SF_OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}${SF_OTHER_PLATFORM}"
else
    echo "Could not find platform name from build products directory: $BUILT_PRODUCTS_DIR"
    exit 1
fi

# 3
# If remnants from a previous build exist, delete them.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi

if [ -d "${SRCROOT}/Release" ]; then
rm -rf "${SRCROOT}/Release"
fi

mkdir "${SRCROOT}/Release"

# 4
# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild -target "${TARGET_NAME}" -configuration Release -arch arm64 -arch armv7 -arch armv7s only_active_arch=no defines_module=yes -sdk "iphoneos"
xcodebuild -target "${TARGET_NAME}" -configuration Release -arch x86_64 -arch i386 only_active_arch=no defines_module=yes -sdk "iphonesimulator"

# 5
# Remove .framework file if exists on Desktop from previous run.
if [ -d "${SF_RELEASE_DIR}/${SF_WRAPPER_NAME}" ]; then
rm -rf "${SF_RELEASE_DIR}/${SF_WRAPPER_NAME}"
fi

ls -l "${SRCROOT}/build/Release-iphoneos/"


# 6
# Copy the device version of framework to Desktop.
cp -r "${SRCROOT}/build/Release-iphoneos/${SF_WRAPPER_NAME}" "${SF_RELEASE_DIR}/${SF_WRAPPER_NAME}"

# 7
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
lipo -create -output "${SF_RELEASE_DIR}/${SF_WRAPPER_NAME}/${FRAMEWORK_NAME}" "${SRCROOT}/build/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${SRCROOT}/build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"



# 8
# Copy the framework back for the Journal app to use
cp -a "${SF_RELEASE_DIR}/${SF_WRAPPER_NAME}" "${SRCROOT}/../Samples/OutbrainDemo"

# 9
# Delete the most recent build.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi