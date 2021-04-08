#!/bin/bash

GCP_API_KEY=$GCP_API_KEY

if [[ $# != 3 ]]; then
echo "parameters are missing"
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


ACCESS_TOKEN="ya29.c.Kp8B-wcVNys3hQbtgDNAP1a7t1fOIqUGrRiGhc0OPFKG2nqe_1OtZjXopOi81ybbG66Q9rizj4xyZDf0pg27r8C4n_myvibYfpCaXybPF_N0dZvB60Td64nZX9r9wUB-J3hTTU9Lzcjem3Z_niYNQiNzSM6YD2l54BOcP73Sx6KCVVxjGqy8nAqN_JeIPqmKcB9zKQtK_Sd3wsU-CisfTk8u"
echo "ACCESS_TOKEN: $ACCESS_TOKEN"

touch sdk-assets-33ff7d65d16b.json
echo $GCP_API_KEY > sdk-assets-33ff7d65d16b.json
ACCESS_TOKEN_2=`./get-access-token.sh sdk-assets-33ff7d65d16b.json "https://www.googleapis.com/auth/devstorage.read_write"

echo "ACCESS_TOKEN_2: $ACCESS_TOKEN_2"

# curl -v --upload-file $FROM_PATH \
	 # -H "Authorization: Bearer $ACCESS_TOKEN" 'https://storage.googleapis.com/outbrain-sdk/$NEW_SDK_VER/$FILE_NAME'



echo ""
echo ""
