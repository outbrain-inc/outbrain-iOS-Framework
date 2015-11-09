#!/bin/bash

cd src
xcodebuild -target OBFramework
cd ..

doxygen doxygen.xml

rm -fr OBSDK-Release
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

# clean up the folder
rm -fr HTML-Documentation/

rm -fr ~/Desktop/Release/iOS/*
mkdir -p ~/Desktop/Release/iOS
mv OBSDK-Release/* ~/Desktop/Release/iOS/
rm -fr OBSDK-Release/*
cd ~/Desktop/Release/iOS

zip -r OBSDK-iOS.zip . -x ".*" -x "*/.*"
cd -
mv ~/Desktop/Release/iOS/OBSDK-iOS.zip OBSDK-Release/
