#!/bin/bash

DEFAULT_CONTAINER_CPU=4
DEFAULT_CONTAINER_MEMORY=8192

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

BIDS_DIR=${2}

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
    if [ -z "${BIDS_DIR}" ]
    then
        echo "Data config or a BIDS directory must be provided."
        exit 1
    else
        if [ ! "${BIDS_DIR:0:5}" = "s3://" ]
        then
            echo "BIDS directory must stored in a S3 bucket. Correct usage: s3://bucket-name/path/to/folder"
            exit 1
        fi
    fi
else
    BIDS_DIR="/"

    if [ ! "${DATA_CONFIG_FILE:0:5}" = "s3://" ]
    then
        echo "Data config must stored in a S3 bucket. Check the provided file: ${DATA_CONFIG_FILE}. Correct usage: s3://bucket-name/path/to/folder/data_config.yml"
        exit 1
    fi
fi

if [ ! -z "${PIPELINE_FILE}" ]
then
    if [ ! "${PIPELINE_FILE:0:5}" = "s3://" ]
    then
        echo "Pipeline file must stored in a S3 bucket. Check the provided file: ${PIPELINE_FILE}. Correct usage: s3://bucket-name/path/to/folder/pipelne.yml"
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

DEFINITION='{
    "vcpus": '${CONTAINER_CPU}',
    "memory": '${CONTAINER_MEMORY}',
    "command": []
}'

DEFINITION=$(jq '.command += ["'${BIDS_DIR}'", "'${OUTPUT_DIR}'", "participant"]' <<< ${DEFINITION})

if [ ! -z "${PIPELINE_FILE}" ]
then
    DEFINITION=$(jq '.command += ["--pipeline_file", "'${PIPELINE_FILE}'"]' <<< ${DEFINITION})
fi

if [ ! -z "${DATA_CONFIG_FILE}" ]
then
    DEFINITION=$(jq '.command += ["--data_config_file", "'${DATA_CONFIG_FILE}'"]' <<< ${DEFINITION})
fi

DEFINITION=$(jq '.command += ["--skip_bids_validator", "--participant_label", ""]' <<< ${DEFINITION})


for PARTICIPANT in ${PARTICIPANTS}
do
    PARTICIPANT_DEFINITION=$(jq '.command[-1] = "'${PARTICIPANT}'"' <<< ${DEFINITION})
    aws batch submit-job \
        --job-name ${PROJECT} \
        --job-queue ${PROJECT} \
        --job-definition ${PROJECT} \
        --container-overrides "${PARTICIPANT_DEFINITION}"
done

# Code to check for logs
# start_time=$(( ( $(date -u +"%s") - $start_seconds_ago ) * 1000 ))
# while [[ -n "$start_time" ]]; do
#   loglines=$( aws --output text logs get-log-events --log-group-name "/aws/batch/job" --log-stream-name "${PROJECT}/default/${JOB_ID}" --start-time $start_time )
#   [ $? -ne 0 ] && break
#   next_start_time=$( sed -nE 's/^EVENTS.([[:digit:]]+).+$/\1/ p' <<< "$loglines" | tail -n1 )
#   [ -n "$next_start_time" ] && start_time=$(( $next_start_time + 1 ))
#   echo "$loglines"
#   sleep 15
# done

exit 0

./process_subjects.sh \
    cpac-batch \
    --n_cpus 4 \
    --mem_gb 8 \
    --data_config_file s3://cpac-batch/data_config.yaml \
    --output_dir s3://cpac-batch/output -- 0050642 0050646 0050647 0050649 0050653 0050654 0050656 0050659 0050660


./process_subjects.sh \
    my-project-cool-name \
    s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS/NYU/ \
    --n_cpus 4 \
    --mem_gb 8 \
    --output_dir s3://cpac-batch/output -- 0051159