#!/bin/bash

EXPORT_DIR_PATH=~/Desktop/Release/iOS
FRAMEWORK_ARTIFACT_PATH=~Samples/OutbrainDemo/OutbrainSDK.framework

BRANCH=`git rev-parse --abbrev-ref HEAD`

echo ""
echo "*********************"
echo " Clean previous Outbrain framework if exists"
echo "*********************"
ls -l $FRAMEWORK_ARTIFACT_PATH
rm -fr $FRAMEWORK_ARTIFACT_PATH
ls -l $FRAMEWORK_ARTIFACT_PATH

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
echo " Building the SDK project"
echo "*********************"
xcodebuild -target OBFramework
cd ..

echo ""
echo "*********************"
echo " Check if framework is where we think it is"
echo "*********************"
ls -l $FRAMEWORK_ARTIFACT_PATH


echo ""
echo "***************************"
echo " Creating OBSDK-Release dir"
echo "***************************"
rm -fr OBSDK-Release
mkdir OBSDK-Release
mkdir OBSDK-Release/SDK/
mkdir OBSDK-Release/Samples/
# mkdir OBSDK-Release/HTML-Documentation/

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
cd /Users/odedre/work/Outbrain/OutbrainDemoSwift
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
cp -a OutbrainSDK.framework Swift-Demo/OutbrainSDK/
echo "--> finally check that the new SDK exists"
ls -l Swift-Demo/OutbrainSDK/


echo ""
echo "*********************"
echo "Prepare OBSDK-iOS.zip"
echo "*********************"
#prepare 
cd $EXPORT_DIR_PATH
zip --symlinks -r iOS-SampleApps.zip . -x ".*" -x "*/.*" > /dev/null
cd /Users/odedre/work/Outbrain/OBSDKiOS
mv $EXPORT_DIR_PATH/iOS-SampleApps.zip OBSDK-Release/




echo ""
echo "*********************"
echo "Success"
echo "*********************"
