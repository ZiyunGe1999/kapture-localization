#!/bin/bash -e
# Run this script in docker,
# but first pull the most recent version.

# docker pull kapture/kapture-localization
# docker run --runtime=nvidia -it --rm --volume <my_data>:<my_data> kapture/kapture-localization
# once the docker container is launched, go to your working directory of your choice (all data will be stored there)
# and run this script from there (of course you can also change WORKING_DIR=${PWD} to something else and run the script from somewhere else)

# 0a) Define paths and params
PYTHONBIN=python3.6
WORKING_DIR=/data/working_dir_MUTC_resized
DATASETS_PATH=/data
DATASET=MUTC_resized
QUERY=query1
mkdir -p ${DATASETS_PATH}
mkdir -p ${WORKING_DIR}

TOPK=20  # number of retrieved images for mapping and localization
KPTS=20000 # number of local features to extract

# 0b) Get extraction code for local and global features
# ! skip if already done !
# Deep Image retrieval - AP-GeM
#pip3 install scikit-learn==0.22 torchvision==0.5.0 gdown tqdm
#pip3 install gdown tqdm
#cd ${WORKING_DIR}
#git clone https://github.com/naver/deep-image-retrieval.git
#cd deep-image-retrieval
#mkdir -p dirtorch/data/
#cd dirtorch/data/
#gdown --id 1r76NLHtJsH-Ybfda4aLkUIoW3EEsi25I # downloads a pre-trained model of AP-GeM
#unzip Resnet101-AP-GeM-LM18.pt.zip
#rm -rf Resnet101-AP-GeM-LM18.pt.zip
# R2D2
#cd ${WORKING_DIR}
#git clone https://github.com/naver/r2d2.git

# 1) Download dataset
# Note that you will be asked to accept or decline the license terms before download.
#mkdir ${DATASETS_PATH}
#kapture_download_dataset.py --install_path ${DATASETS_PATH} update
#kapture_download_dataset.py --install_path ${DATASETS_PATH} install ${DATASET}_mapping ${DATASET}_query_day ${DATASET}_query_night
#rm -rf ${DATASETS_PATH}/${DATASET}/mapping/reconstruction # remove the keypoints and 3D points that come with the dataset (this is Aachen specific)
#kapture_merge.py -v debug \
#  -i ${DATASETS_PATH}/${DATASET}/query_day ${DATASETS_PATH}/${DATASET}/query_night \
#  -o ${DATASETS_PATH}/${DATASET}/query \
#  --image_transfer link_relative

# 2) Create temporal mapping sets (they will be modified)
#mkdir -p ${WORKING_DIR}/${DATASET}/mapping/sensors
#cp ${DATASETS_PATH}/${DATASET}/mapping/sensors/*.txt ${WORKING_DIR}/${DATASET}/mapping/sensors/
#ln -s ${DATASETS_PATH}/${DATASET}/mapping/sensors/records_data ${WORKING_DIR}/${DATASET}/mapping/sensors/records_data

#mkdir -p ${WORKING_DIR}/${DATASET}/query/sensors
#cp ${DATASETS_PATH}/${DATASET}/query/sensors/*.txt ${WORKING_DIR}/${DATASET}/query/sensors/
#ln -s ${DATASETS_PATH}/${DATASET}/query/sensors/records_data ${WORKING_DIR}/${DATASET}/query/sensors/records_data

# 3) Merge mapping and query kaptures (this will make it easier to extract the local and global features and it will be used for the localization step)
#kapture_merge.py -v debug \
#  -i ${WORKING_DIR}/${DATASET}/mapping ${WORKING_DIR}/${DATASET}/query \
#  -o ${WORKING_DIR}/${DATASET}/map_plus_query \
#  --image_transfer link_relative

# 4) Extract global features for mapping dataset (we will use AP-GeM here)
#cd ${WORKING_DIR}/deep-image-retrieval
#${PYTHONBIN} -m dirtorch.extract_kapture --kapture-root ${WORKING_DIR}/${DATASET}/mapping/ --checkpoint dirtorch/data/Resnet101-AP-GeM-LM18.pt --gpu 0
# move to right location
#mkdir -p ${WORKING_DIR}/${DATASET}/global_features/Resnet101-AP-GeM-LM18/global_features
#mv ${WORKING_DIR}/${DATASET}/mapping/reconstruction/global_features/Resnet101-AP-GeM-LM18/* ${WORKING_DIR}/${DATASET}/global_features/Resnet101-AP-GeM-LM18/global_features/
#rm -rf ${WORKING_DIR}/${DATASET}/mapping/reconstruction/global_features/Resnet101-AP-GeM-LM18

# 5) Extract local features for mapping dataset (we will use R2D2 here)
#cd ${WORKING_DIR}/r2d2
#${PYTHONBIN} extract_kapture.py --model models/r2d2_WASF_N8_big.pt --kapture-root ${WORKING_DIR}/${DATASET}/mapping/ --min-scale 0.3 --min-size 128 --max-size 9999 --top-k ${KPTS}
# move to right location
#mkdir -p ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/descriptors
#mv ${WORKING_DIR}/${DATASET}/mapping/reconstruction/descriptors/r2d2_WASF_N8_big/* ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/descriptors/
#mkdir -p ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/keypoints
#mv ${WORKING_DIR}/${DATASET}/mapping/reconstruction/keypoints/r2d2_WASF_N8_big/* ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/keypoints/

# 6) mapping pipeline
#LOCAL=r2d2_WASF_N8_big
#GLOBAL=Resnet101-AP-GeM-LM18
#kapture_pipeline_mapping.py -v debug -f \
#  -i ${WORKING_DIR}/${DATASET}/mapping \
#  -kpt ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/keypoints \
#  -desc ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/descriptors \
#  -gfeat ${WORKING_DIR}/${DATASET}/global_features/${GLOBAL}/global_features \
#  -matches ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/NN_no_gv/matches \
#  -matches-gv ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/NN_colmap_gv/matches \
#  --colmap-map ${WORKING_DIR}/${DATASET}/colmap-sfm/${LOCAL}/${GLOBAL} \
#  --topk ${TOPK}

# 7) Create temporal query sets (they will be modified)
#mkdir -p ${WORKING_DIR}/${DATASET}/${QUERY}/sensors
#cp ${DATASETS_PATH}/${DATASET}/${QUERY}/sensors/*.txt ${WORKING_DIR}/${DATASET}/${QUERY}/sensors/
#ln -s ${DATASETS_PATH}/${DATASET}/${QUERY}/sensors/records_data ${WORKING_DIR}/${DATASET}/${QUERY}/sensors/records_data

# 8) Extract global features for query dataset (we will use AP-GeM here)
echo 'start extracting global features'
#cd ${WORKING_DIR}/deep-image-retrieval
#${PYTHONBIN} -m dirtorch.extract_kapture --kapture-root ${WORKING_DIR}/${DATASET}/${QUERY}/ --checkpoint dirtorch/data/Resnet101-AP-GeM-LM18.pt --gpu 0
## move to right location
#mkdir -p ${WORKING_DIR}/${DATASET}/global_features/Resnet101-AP-GeM-LM18/global_features
#rsync -a ${WORKING_DIR}/${DATASET}/${QUERY}/reconstruction/global_features/Resnet101-AP-GeM-LM18/ ${WORKING_DIR}/${DATASET}/global_features/Resnet101-AP-GeM-LM18/global_features/
#rm -rf ${WORKING_DIR}/${DATASET}/${QUERY}/reconstruction/global_features/Resnet101-AP-GeM-LM18
#
## 9) Extract local features for query dataset (we will use R2D2 here)
echo 'start extracting local features'
#cd ${WORKING_DIR}/r2d2
#${PYTHONBIN} extract_kapture.py --model models/r2d2_WASF_N8_big.pt --kapture-root ${WORKING_DIR}/${DATASET}/${QUERY}/ --min-scale 0.3 --min-size 128 --max-size 9999 --top-k ${KPTS}
## move to right location
#mkdir -p ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/descriptors
#rsync -a ${WORKING_DIR}/${DATASET}/${QUERY}/reconstruction/descriptors/r2d2_WASF_N8_big/ ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/descriptors/
#mkdir -p ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/keypoints
#rsync -a ${WORKING_DIR}/${DATASET}/${QUERY}/reconstruction/keypoints/r2d2_WASF_N8_big/ ${WORKING_DIR}/${DATASET}/local_features/r2d2_WASF_N8_big/keypoints/
#
## 10) localization pipeline
echo 'start localize'
LOCAL=r2d2_WASF_N8_big
GLOBAL=Resnet101-AP-GeM-LM18
kapture_pipeline_localize.py -v debug -f \
  -i ${WORKING_DIR}/${DATASET}/mapping \
  --query ${WORKING_DIR}/${DATASET}/${QUERY} \
  -kpt ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/keypoints \
  -desc ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/descriptors \
  -gfeat ${WORKING_DIR}/${DATASET}/global_features/${GLOBAL}/global_features \
  -matches ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/NN_no_gv/matches \
  -matches-gv ${WORKING_DIR}/${DATASET}/local_features/${LOCAL}/NN_colmap_gv/matches \
  --colmap-map ${WORKING_DIR}/${DATASET}/colmap-sfm/${LOCAL}/${GLOBAL} \
  -o ${WORKING_DIR}/${DATASET}/colmap-localize-${QUERY}/${LOCAL}/${GLOBAL} \
  --topk ${TOPK} \
  --config 2 \
  -s compute_matches geometric_verification colmap_localize import_colmap evaluate export_LTVL2020
