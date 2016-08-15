#!/bin/bash

EXPORT_DIR_PATH=~/Desktop/Release/iOS

BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ $BRANCH != "master" ]; then
	echo "Error - This script should be executed only from master branch"
	echo ""
	exit 1
fi;

cd src
# Clean
xcodebuild clean -target OBFramework
xcodebuild clean -target OutbrainSDK

# Build
xcodebuild -target OBFramework
cd ..

# doxygen doxygen.xml

rm -fr OBSDK-Release
mkdir OBSDK-Release
mkdir OBSDK-Release/SDK/
mkdir OBSDK-Release/Samples/
# mkdir OBSDK-Release/HTML-Documentation/


cp -a OutbrainSDK.framework OBSDK-Release/SDK/
cp -a OutbrainSDK.framework OBSDK-Release/Samples/
cp -fa Samples/ OBSDK-Release/Samples/
cp -rf README.md OBSDK-Release/
cp -rf Release-Notes.txt OBSDK-Release/

# clean up the export folder
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
echo " JS Widget Sample App"
echo "*********************"
cd /Users/odedre/work/Outbrain/JSWidgetSampleApp
git status
git archive --format zip --output /Users/odedre/work/Outbrain/OBSDKiOS/OBSDK-Release/JSWidgetSampleApp.zip master

echo ""
echo "*********************"
echo " API Endpoint Sample App"
echo "*********************"
cd /Users/odedre/work/Outbrain/EndpointAPISampleApp
git status
git archive --format zip --output /Users/odedre/work/Outbrain/OBSDKiOS/OBSDK-Release/EndpointAPISampleApp.zip master


echo ""
echo "*********************"
echo "Success"
echo "*********************"
