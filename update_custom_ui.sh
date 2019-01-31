#!/bin/bash

if [ $# -eq 0 ]; then
echo "version parameter is missing"
exit 1
fi

NEW_SDK_VER=$1

echo ""
echo "*************************************"
echo "* Running script - update Custom UI *"
echo "*************************************"

echo ""
echo "****************************"
echo " Creating OBSDK-CustomUI dir"
echo "****************************"
rm -fr OBSDK-CustomUI
mkdir OBSDK-CustomUI
mkdir OBSDK-CustomUI/SFSingleCells/
mkdir OBSDK-CustomUI/SFHeaderCells/

echo ""
echo "****************************************"
echo " Copy Custom UI files to OBSDK-CustomUI"
echo "****************************************"

SINGLE_CELLS_PATH="SDK-sources/OutbrainSDK/SmartFeed/SFSingleCells"
HEADER_CELLS_PATH="SDK-sources/OutbrainSDK/SmartFeed/SmartFeedHeaderCells/XIB"

cp -r ${SINGLE_CELLS_PATH}/ OBSDK-CustomUI/SFSingleCells/
cp -r ${HEADER_CELLS_PATH}/SFTableViewHeaderCell.xib OBSDK-CustomUI/SFHeaderCells/
cp -r ${HEADER_CELLS_PATH}/SFCollectionViewHeaderCell.xib OBSDK-CustomUI/SFHeaderCells/

echo ""
echo "*********************************************************"
echo " zip Custom UI files to Custom-UI-iOS-SDK-Smartfeed.zip"
echo "*********************************************************"

cd OBSDK-CustomUI/
zip -r Custom-UI-iOS-SDK-Smartfeed.zip .
rm -fr SFSingleCells/
rm -fr SFHeaderCells/
cd ..

echo ""
echo "*******************"
echo " Upload to Bintray "
echo "*******************"

PACKAGE_IOS_CUSTOM_UI="iOS-Custom-UI-SDK-Smartfeed"

./upload_to_bintray.sh OBSDK-CustomUI/Custom-UI-iOS-SDK-Smartfeed.zip $PACKAGE_IOS_CUSTOM_UI $NEW_SDK_VER Custom-UI-iOS-SDK-Smartfeed.zip

echo ""
echo ""
echo "***************************"
echo "* Finish update Custom UI *"
echo "***************************"

