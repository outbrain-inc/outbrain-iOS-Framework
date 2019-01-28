#!/bin/bash

EXPORT_DIR_PATH=~/Desktop/Release/iOS
FRAMEWORK_ARTIFACT_PATH=Samples/OutbrainDemo/OutbrainSDK.framework

BASE_FOLDER=`pwd`
BRANCH=`git rev-parse --abbrev-ref HEAD`

OUTBRAIN_SDK_M_PATH="SDK-sources/OutbrainSDK/Outbrain.m"
CURRENT_SDK_VERSION=`cat $OUTBRAIN_SDK_M_PATH | grep "OB_SDK_VERSION" | cut -d "=" -f2 | cut -d \" -f2`

if [ $# -eq 0 ]; then
echo "version parameter is missing"
exit 1
fi

NEW_SDK_VER=$1

if [ -d "$FRAMEWORK_ARTIFACT_PATH" ]; then
	echo ""
	echo "*********************"
	echo " Clean previous OutbrainSDK.framework"
	echo "*********************"
	rm -fr $FRAMEWORK_ARTIFACT_PATH
fi

# Version update
echo ""
echo "*********************"
echo " Updating SDK version from ${CURRENT_SDK_VERSION} to ${NEW_SDK_VER}"
echo "*********************"
./update_version.sh ${NEW_SDK_VER}

git add SDK-sources/OutbrainSDK/Outbrain.m
git add Samples/OutbrainDemo/Journal/Resources/plists/Journal-Dev-Info.plist
git add Samples/OutbrainDemo/Journal/Resources/plists/Journal-Info.plist
git add Samples/OutbrainDemo/SmartFeed/Resources/SmartFeed-Dev-Info.plist
git add Samples/OutbrainDemo/SmartFeed/Resources/SmartFeed-Info.plist

git commit -m "update version to ${NEW_SDK_VER}"
git push

cd SDK-sources
# Clean
echo ""
echo "*********************"
echo " Cleaing the SDK project"
echo "*********************"
xcodebuild clean -target OBFramework
xcodebuild clean -target OutbrainSDK


# Build
echo ""
echo "*********************"
echo " Building the SDK project (version ${NEW_SDK_VER})"
echo "*********************"
xcodebuild -target OBFramework
cd ..

echo ""
echo "*********************"
echo " Check if framework is where we think it is"
echo "*********************"
if [ ! -d "$FRAMEWORK_ARTIFACT_PATH" ]; then
	echo "framework is NOT where we think it is"
	exit 1
fi


echo ""
echo "***************************"
echo " Creating OBSDK-Release dir"
echo "***************************"
rm -fr OBSDK-Release
mkdir OBSDK-Release
mkdir OBSDK-Release/SDK/
mkdir OBSDK-Release/Samples/


echo ""
echo "***********************************************************"
echo " Copy the OutbrainSDK.framework into OBSDK-Release"
echo "***********************************************************"
cp -a $FRAMEWORK_ARTIFACT_PATH OBSDK-Release/SDK/
cp -fa Samples/ OBSDK-Release/Samples/
cp -rf README.md OBSDK-Release/

# clean up the export folder
echo ""
echo "***********************************************************"
echo " Copy the content of OBSDK-Release to ${EXPORT_DIR_PATH}"
echo "***********************************************************"
rm -fr $EXPORT_DIR_PATH
mkdir -p $EXPORT_DIR_PATH
mv OBSDK-Release/* $EXPORT_DIR_PATH
rm -fr OBSDK-Release/*

echo ""
echo "*********************"
echo "Swift Sample App"
echo "*********************"
cd ../OutbrainDemoSwift
git status
git archive --format zip --output $EXPORT_DIR_PATH/Samples/Swift-Demo.zip master
cd $EXPORT_DIR_PATH/Samples
unzip Swift-Demo.zip -d Swift-Demo  > /dev/null
rm -fr Swift-Demo.zip


echo "--> check if the original SDK exists"
ls -l Swift-Demo/OutbrainSDK/
echo "--> remove the original SDK from the git repo"
rm -fr Swift-Demo/OutbrainSDK/OutbrainSDK.framework
echo "--> check again if the original SDK exists"
ls -l Swift-Demo/OutbrainSDK/
echo "--> now copy the current SDK from this build"
cp -a ../SDK/OutbrainSDK.framework Swift-Demo/OutbrainSDK/
echo "--> finally check that the new SDK exists"
ls -l Swift-Demo/OutbrainSDK/
if [ ! -d Swift-Demo/OutbrainSDK/OutbrainSDK.framework ]; then
	echo "framework is NOT where we think it is"
	exit 1
fi


echo ""
echo "*********************"
echo "Prepare iOS-SampleApps.zip and OutbrainSDK.framework.zip"
echo "*********************"
#prepare 
cd $EXPORT_DIR_PATH
zip --symlinks -r iOS-SampleApps.zip . -x ".*" -x "*/.*" > /dev/null
cd SDK/OutbrainSDK.framework > /dev/null
zip --symlinks -r ../../OutbrainSDK.framework.zip *
cd $BASE_FOLDER
mv $EXPORT_DIR_PATH/iOS-SampleApps.zip OBSDK-Release/
mv $EXPORT_DIR_PATH/OutbrainSDK.framework.zip OBSDK-Release/

open OBSDK-Release

echo ""
echo "*********************"
echo "Uploading iOS-SampleApps.zip and OutbrainSDK.framework.zip to Bintray"
echo "*********************"
#Uploading to Bintray
API_KEY="bdf87de700d2dffd65fe3aeb23d13122a3406a0b"
REPO="obsdk"
PACKAGE_SDK="iOS-SDK"
PACKAGE_SAMPLE_APPS="iOS-SampleApps"

echo ""
echo "Upload OutbrainSDK.framework.zip to Bintray"
curl -T OBSDK-Release/OutbrainSDK.framework.zip -uoutbrainmobileadmin:$API_KEY https://api.bintray.com/content/outbrainmobile/$REPO/$PACKAGE_SDK/$NEW_SDK_VER/$NEW_SDK_VER/OutbrainSDK.framework.zip?publish=1

echo ""
echo "Upload iOS-SampleApps.zip to Bintray"
curl -T OBSDK-Release/iOS-SampleApps.zip -uoutbrainmobileadmin:$API_KEY https://api.bintray.com/content/outbrainmobile/$REPO/$PACKAGE_SAMPLE_APPS/$NEW_SDK_VER/$NEW_SDK_VER/iOS-SampleApps.zip?publish=1

echo ""
echo "*********************"
echo "Success"
echo "*********************"
echo ""
echo "*********************************************************************************************************"
echo "Links:"
echo ""
echo "iOS Sample Apps on bintray:"
echo "https://dl.bintray.com/outbrainmobile/obsdk/$NEW_SDK_VER/iOS-SampleApps.zip"
echo ""
echo "iOS SDK on bintray:"
echo "https://dl.bintray.com/outbrainmobile/obsdk/$NEW_SDK_VER/OutbrainSDK.framework.zip"
echo "*********************************************************************************************************"

