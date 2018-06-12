#!/bin/bash

AWS_REGION="us-east-1"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --aws_region)
            AWS_REGION="$2"
            shift
            shift
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

terraform destroy \
    -var "project=${PROJECT}" \
    -var "aws_region=${AWS_REGION}" \
    -var "batch_max_vcpus=0" \
    -var "public_key_path=/dev/null" \
    tf

exit 0

./destroy_infra.sh cpac-batch