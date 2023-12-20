#!/bin/bash

echo "**************************************************"
echo "* Run Script - Bump SDK version *"
echo "**************************************************"
echo ""
echo ""

echo ""
echo "*********************"
echo " Updating SDK version from ${CURRENT_SDK_VERSION} to ${RELEASE_VERSION}"
echo "*********************"
./update_version.sh ${RELEASE_VERSION}

cd ..

git add SwiftSDK-sources/OutbrainSDK/Outbrain.swift
git add Samples/OutbrainDemo/Journal/Resources/plists/Journal-Dev-Info.plist
git add Samples/OutbrainDemo/Journal/Resources/plists/Journal-Info.plist
git add Samples/OutbrainDemo/SmartFeed/Resources/SmartFeed-Dev-Info.plist
git add Samples/OutbrainDemo/SmartFeed/Resources/SmartFeed-Info.plist
git add Samples/OutbrainDemo/SFWebView-Dev/Info.plist
git add Samples/OutbrainDemo/SFWebView-Prod/SFWebView-Prod-Info.plist 


git config credential.helper 'cache --timeout=120'
git config --global user.email "oregev@outbrain.com"
git config --global user.name "Oded Regev via CircleCI"
git commit -m "[skip ci] Update SDK version to ${RELEASE_VERSION}"
git tag "release_${RELEASE_VERSION}"
git push origin $CIRCLE_BRANCH
git push origin --tags
