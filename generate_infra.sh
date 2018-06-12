#!/bin/bash

AWS_REGION="us-east-1"
MAX_CPUS="16"
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

echo "
*** Warning: It is using a tweaked C-PAC to work with AWS. Run 'git pull' from time to time to check for official updates. ***
"

terraform apply \
    -var "project=${PROJECT}" \
    -var "aws_region=${AWS_REGION}" \
    -var "batch_max_vcpus=${MAX_CPUS}" \
    -var "public_key_path=${PUBLIC_KEY_FILE}" \
    tf

exit 0

./generate_infra.sh cpac-batch --max_cpu 16 --instance_type c4.4xlarge