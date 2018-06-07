#!/bin/bash

INSTANCE_TYPE="c4.large"
AWS_REGION="us-east-1"
MAX_CPUS="5"
PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --max_cpu)
            MAX_CPUS="$2"
            shift
            shift
        ;;
        --public_key_path)
            PUBLIC_KEY_FILE="$2"
            shift
            shift
        ;;
        --aws_region)
            AWS_REGION="$2"
            shift
            shift
        ;;
        --instance_type)
            INSTANCE_TYPE="$2"
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

if [[ ! -f $PUBLIC_KEY_FILE ]]; then
    echo "$PUBLIC_KEY_FILE is not a valid key file."
    exit 1
fi

terraform destroy \
    -var "project=${PROJECT}" \
    -var "aws_region=${AWS_REGION}" \
    -var "batch_instance_type=${INSTANCE_TYPE}" \
    -var "batch_max_vcpus=${MAX_CPUS}" \
    -var "public_key_path=${PUBLIC_KEY_FILE}"

exit 0

./destroy_infra.sh cpac-batch --max_cpu 5 --instance_type c4.large