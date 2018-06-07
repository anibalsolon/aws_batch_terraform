#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
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

aws batch list-jobs --job-queue ${PROJECT} --job-status SUBMITTED --output text
aws batch list-jobs --job-queue ${PROJECT} --job-status PENDING --output text
aws batch list-jobs --job-queue ${PROJECT} --job-status RUNNABLE --output text
aws batch list-jobs --job-queue ${PROJECT} --job-status STARTING --output text
aws batch list-jobs --job-queue ${PROJECT} --job-status RUNNING --output text
aws batch list-jobs --job-queue ${PROJECT} --job-status SUCCEEDED --output text
aws batch list-jobs --job-queue ${PROJECT} --job-status FAILED --output text

exit 0
