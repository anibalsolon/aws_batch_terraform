#!/bin/bash

DEFAULT_PIPELINE_FILE="/cpac_resources/default_pipeline.yaml"
DEFAULT_CONTAINER_CPU=2
DEFAULT_CONTAINER_MEMORY=3072

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --data_config_file)
            DATA_CONFIG_FILE="$2"
            shift
            shift
        ;;
        --pipeline_file)
            PIPELINE_FILE="$2"
            shift
            shift
        ;;
        --output_dir)
            OUTPUT_DIR="$2"
            shift
            shift
        ;;
        --n_cpus)
            CONTAINER_CPU="$2"
            shift
            shift
        ;;
        --mem_gb)
            CONTAINER_MEMORY_GB=$(( $2 * 1024 ))
            shift
            shift
        ;;
        --mem_mb)
            CONTAINER_MEMORY_MB="$2"
            shift
        ;;
        --)
            shift
            PARTICIPANTS=$@
            break
        ;;
        *)
            POSITIONAL+=("$1")
            shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}"

PROJECT=${1}

if [ -z "${PROJECT}" ]
then
    echo "Project name not provided."
    exit 1
fi

CONTAINER_CPU=${CONTAINER_CPU-${DEFAULT_CONTAINER_CPU}}

if [ ! -z "${CONTAINER_MEMORY_GB}" ]
then
    CONTAINER_MEMORY=${CONTAINER_MEMORY_GB}
else
    if [ ! -z "${CONTAINER_MEMORY_MB}" ]
    then
        CONTAINER_MEMORY=${CONTAINER_MEMORY_MB}
    else
        CONTAINER_MEMORY=${DEFAULT_CONTAINER_MEMORY}
    fi
fi

if [ -z "${DATA_CONFIG_FILE}" ]
then
    echo "Data config file not provided. Use --data_config_file to set a data config file. It must be stored in a S3 bucket: s3://bucket-name/path/to/folder"
    exit 1
else
    if [ ! "${DATA_CONFIG_FILE:0:5}" = "s3://" ]
    then
        echo "Data config must stored in a S3 bucket. Check the provided file: ${DATA_CONFIG_FILE}. Correct usage: s3://bucket-name/path/to/folder"
        exit 1
    fi
fi

if [ -z "${PIPELINE_FILE}" ]
then
    PIPELINE_FILE=${DEFAULT_PIPELINE_FILE}
else
    if [ ! "${PIPELINE_FILE:0:5}" = "s3://" ]
    then
        echo "Pipeline file must stored in a S3 bucket. Check the provided file: ${PIPELINE_FILE}. Correct usage: s3://bucket-name/path/to/folder"
        exit 1
    fi
fi

if [ -z "${OUTPUT_DIR}" ]
then
    echo "Output dir not provided. Use --output_dir to set an output dir. It must be stored in a S3 bucket: s3://bucket-name/path/to/folder"
    exit 1
else
    if [ ! "${OUTPUT_DIR:0:5}" = "s3://" ]
    then
        echo "Output dir must stored in a S3 bucket. Check the provided dir: ${OUTPUT_DIR}. Correct usage: s3://bucket-name/path/to/folder"
        exit 1
    fi
fi

for PARTICIPANT in ${PARTICIPANTS}
do
    aws batch submit-job \
        --job-name ${PROJECT} \
        --job-queue ${PROJECT} \
        --job-definition ${PROJECT} \
        --container-overrides "{
            \"vcpus\": ${CONTAINER_CPU},
            \"memory\": ${CONTAINER_MEMORY},
            \"command\": [
                \"--participant_label\", \"$PARTICIPANT\",
                \"--pipeline_file\", \"${PIPELINE_FILE}\",
                \"--data_config_file\", \"${DATA_CONFIG_FILE}\",
                \"/\", \"${OUTPUT_DIR}\", \"participant\"
            ]
        }"
done

exit 0

./process_subjects.sh \
    cpac-batch \
    --n_cpus 2 \
    --mem_gb 2 \
    --pipeline_file s3://cpac-batch/pipeline_config.yaml \
    --data_config_file s3://cpac-batch/data_config.yaml \
    --output_dir s3://cpac-batch/output -- 0050642 0050646 0050647 0050649 0050653 0050654 0050656 0050659 0050660


./process_subjects.sh \
    cpac-batch \
    --n_cpus 2 \
    --mem_gb 2 \
    --pipeline_file s3://cpac-batch/pipeline_config.yaml \
    --data_config_file s3://cpac-batch/data_config.yaml \
    --output_dir s3://cpac-batch/output -- 0050642