#!/bin/bash

sudo xcodebuild -target OBFramework

cd ..
doxygen doxygen.xml

mkdir OBSDK-Release
mkdir OBSDK-Release/SDK/
mkdir OBSDK-Release/Samples/
mkdir OBSDK-Release/HTML-Documentation/

cp -rf OutbrainSDK.framework OBSDK-Release/SDK/
cp -rf Samples/ OBSDK-Release/Samples/
cp -rf OutbrainSDK.framework OBSDK-Release/Samples/
cp -rf HTML-Documentation/ OBSDK-Release/HTML-Documentation/
cp -rf README.md OBSDK-Release/
cp -rf Release-Notes.txt OBSDK-Release/

mkdir ~/Desktop/Release/iOS
mv OBSDK-Release/* ~/Desktop/Release/iOS/
cd ~/Desktop/Release/iOS
zip -r OBSDK-iOS.zip . -x ".*" -x "*/.*"
mv OBSDK-iOS.zip .
