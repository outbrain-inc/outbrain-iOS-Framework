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
mkdir OBSDK-CustomUI/SFReadMoreModuleCells/

echo ""
echo "****************************************"
echo " Copy Custom UI files to OBSDK-CustomUI"
echo "****************************************"

SINGLE_CELLS_PATH="SDK-sources/OutbrainSDK/SmartFeed/SFSingleCells"
HEADER_CELLS_PATH="SDK-sources/OutbrainSDK/SmartFeed/SmartFeedHeaderCells/XIB"
READ_MORE_MODULE_CELLS_PATH="SDK-sources/OutbrainSDK/SmartFeed/ReadMoreModule/ReadMoreModuleCells/XIB"

cp -r ${SINGLE_CELLS_PATH}/ OBSDK-CustomUI/SFSingleCells/
cp -r ${HEADER_CELLS_PATH}/SFTableViewHeaderCell.xib OBSDK-CustomUI/SFHeaderCells/
cp -r ${HEADER_CELLS_PATH}/SFCollectionViewHeaderCell.xib OBSDK-CustomUI/SFHeaderCells/
cp -r ${READ_MORE_MODULE_CELLS_PATH}/ OBSDK-CustomUI/SFReadMoreModuleCells/

echo ""
echo "*********************************************************"
echo " zip Custom UI files to Custom-UI-iOS-SDK-Smartfeed.zip"
echo "*********************************************************"

cd OBSDK-CustomUI/
zip -r Custom-UI-iOS-SDK-Smartfeed.zip .
rm -fr SFSingleCells/
rm -fr SFHeaderCells/
rm -fr SFReadMoreModuleCells/
cd ..

echo ""
echo "*******************"
echo " Upload to GCP Storage "
echo "*******************"

pwd
ls -l OBSDK-CustomUI/Custom-UI-iOS-SDK-Smartfeed.zip

cd scripts
./upload_to_gcp_storage.sh ../OBSDK-CustomUI/Custom-UI-iOS-SDK-Smartfeed.zip Custom-UI-iOS-SDK-Smartfeed.zip $NEW_SDK_VER

echo ""
echo ""
echo "***************************"
echo "* Finish update Custom UI *"
echo "***************************"
