#!/bin/bash



if [[ $# != 3 ]]; then
	echo "parameters are missing"
	echo "./upload_to_gcp_storage.sh FROM_PATH  FILE_NAME  NEW_SDK_VER"
	exit 1
fi

FROM_PATH=$1
FILE_NAME=$2
NEW_SDK_VER=$3


echo ""
echo "*************************************************************************"
echo " Upload ${FILE_NAME} to GCP Storage (version ${NEW_SDK_VER})"
echo " From path: ${FROM_PATH}"
echo "*************************************************************************"
echo ""


echo "Request Access Token From GCP..."
touch sdk-assets-33ff7d65d16b.json
echo $GCP_API_KEY > sdk-assets-33ff7d65d16b.json
ACCESS_TOKEN=`./get-access-token.sh sdk-assets-33ff7d65d16b.json "https://www.googleapis.com/auth/devstorage.read_write"`

echo "Upload file to GCP with Access Token"

curl -v --upload-file $FROM_PATH \
	 -H "Authorization: Bearer $ACCESS_TOKEN" "https://storage.googleapis.com/outbrain-sdk/$NEW_SDK_VER/$FILE_NAME"



echo ""
echo ""
