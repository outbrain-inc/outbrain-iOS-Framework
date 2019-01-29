#!/bin/bash

API_KEY="bdf87de700d2dffd65fe3aeb23d13122a3406a0b"
REPO="obsdk"

if [[ $# != 4 ]]; then
echo "parameters are missing"
exit 1
fi

FROM_PATH=$1
PACKAGE=$2
NEW_SDK_VER=$3
FILE_NAME=$4


echo ""
echo "*************************************************************************"
echo " Upload ${FILE_NAME} to Bintray (version ${NEW_SDK_VER})"
echo " Package: ${PACKAGE}"
echo " From path: ${FROM_PATH}"
echo "*************************************************************************"
echo ""

curl -T $FROM_PATH -uoutbrainmobileadmin:$API_KEY https://api.bintray.com/content/outbrainmobile/$REPO/$PACKAGE/$NEW_SDK_VER/$NEW_SDK_VER/$FILE_NAME?publish=1

echo ""
echo ""
