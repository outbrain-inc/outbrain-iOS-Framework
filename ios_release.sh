#!/bin/bash

EXPORT_DIR_PATH=~/Desktop/Release/iOS

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
echo "Prepare Zip File"
echo "*********************"
#prepare 
cd $EXPORT_DIR_PATH
zip --symlinks -r OBSDK-iOS.zip . -x ".*" -x "*/.*" > /dev/null

cd /Users/odedre/work/OBSDKiOS
mv $EXPORT_DIR_PATH/OBSDK-iOS.zip OBSDK-Release/

echo ""
echo "*********************"
echo "Success"
echo "*********************"
