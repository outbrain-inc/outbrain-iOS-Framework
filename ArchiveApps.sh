#!/bin/bash

echo "Enter App:"
echo "1: Catalog"
echo "2: Journal"
echo "3: Catalog-iPad"
echo "4: OBSDK"
echo "5: Release SDK"

read APP_NUMBER
echo

if [ $APP_NUMBER == "1" ] ; then
    APP_NAME='Catalog'
    APP_PROVISIONING='Catalog'
fi

if [ $APP_NUMBER == "2" ] ; then
    APP_NAME='Journal'
    APP_PROVISIONING='Journal'
fi

if [ $APP_NUMBER == "3" ] ; then
    APP_NAME='Catalog-iPad'
    APP_PROVISIONING='Catalog iPad'
fi

if [ $APP_NUMBER == "4" ] ; then
    cd src
    xcodebuild -target OBFramework
    exit
fi

if [ $APP_NUMBER == "5" ] ; then
    cd src
    xcodebuild -target OBFramework
    
    cd ..
    mkdir OBSDK
    cp -rf OutbrainSDK.framework OBSDK/
    cp -rf OutbrainSDK.framework Samples/
    cp -rf README.md OBSDK/
    zip -r OBSDK.zip OBSDK/ Samples/ README.md release-notes.txt

    exit
fi

cd Samples/OutbrainDemo/
xcodebuild -scheme $APP_NAME archive -archivePath "~/Desktop/$APP_NAME.xcarchive"
xcodebuild -exportArchive -exportFormat ipa -archivePath "~/Desktop/$APP_NAME.xcarchive" -exportPath "~/Desktop/$APP_NAME.ipa" -exportProvisioningProfile "$APP_PROVISIONING app - inhouse"



