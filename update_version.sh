#!/bin/bash

OUTBRAIN_SDK_M_PATH="SDK-sources/OutbrainSDK/Outbrain.m"

if [ "$1" != "" ]; then
    echo "updating version to --> $1"
else
    echo "version parameter is missing is empty"
    exit 1
fi

echo ""
echo "- edit the plist files"
plutil -replace CFBundleShortVersionString -string $1 ./Samples/OutbrainDemo/Journal/Resources/plists/Journal-Info.plist
plutil -replace CFBundleShortVersionString -string $1 ./Samples/OutbrainDemo/SmartFeed/Resources/SmartFeed-Info.plist
plutil -replace CFBundleShortVersionString -string $1 ./Samples/OutbrainDemo/SmartFeed/Resources/SmartFeed-Dev-Info.plist
plutil -replace CFBundleShortVersionString -string $1 ./Samples/OutbrainDemo/Journal/Resources/plists/Journal-Dev-Info.plist

echo ""
echo "- edit the Outbrain.m file"
PREVIOUS_SDK_VERSION=`cat $OUTBRAIN_SDK_M_PATH | grep "OB_SDK_VERSION" | cut -d "=" -f2 | cut -d \" -f2`
echo "- replacing previous version ($PREVIOUS_SDK_VERSION) with current version ($1)"
sed -i '' -e "s/${PREVIOUS_SDK_VERSION}/${1}/g" $OUTBRAIN_SDK_M_PATH

git status
