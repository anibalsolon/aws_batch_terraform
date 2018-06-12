# Running C-PAC in AWS Batch

This set of scripts and Terraform definitions will help you to seamlessly build up your own infrastructure on AWS, run preprocessing of your subjects, and turn off the infrastructure.

> Warning: This is using a tweaked C-PAC to work with AWS. Run 'git pull' from time to time to check for official updates.

## Pre-requisites

First, you need to install and configurate the AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
And authenticate with your access and secret key: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

Now, you need to install Terraform: https://www.terraform.io/intro/getting-started/install.html

You are ready to start preprocessing!

## Setting up your data

In order to preprocess your neuroimages on AWS, the data must be on a S3 bucket, along with the data config and pipeline config YAML file.

The user that you use to configure AWS CLI should have access to the S3 bucket.

## Building up the infrastructure

Please check your current limits of running instances on AWS: https://console.aws.amazon.com/ec2/v2/home#Limits:
You can open a support ticket on AWS to raise these limits.

To build the infrastructure, you should run:
```bash
./generate_infra.sh my-project-cool-name --max_cpu 16 --instance_type c4.4xlarge
```

*c4.4xlarge* is the AWS instance type that we recommend to run C-PAC.

It will show which AWS resources are going to be created. You need to confirm it with an "yes".

After some time, your infrastructure will be ready to run your first job.

## Preprocessing subjects

To start your preprocessing task, you may run the following command, replacing `--pipeline_file` and `--data_config_file` 
to the configs in your bucket, and `--output_dir` with the bucket path for outputting derivatives from the pipeline.

```bash
./process_subjects.sh \
    my-project-cool-name \
    --pipeline_file s3://my-bucket/pipeline_config.yaml \
    --data_config_file s3://my-bucket/data_config.yaml \
    --output_dir s3://my-bucket/cpac_output -- 0000001 0000002 0000003 0000004
```

It will schedule a job for each subject, so AWS Batch manager will parallelise all subject pipelines.

The output will be uploaded to the informed bucket.

## Destroying your infrastructure

After your analysis finishes, and you do not need the infrastructure anymore, you can safely destroy the infrastructure.

```bash
./destroy_infra.sh \
    my-project-cool-name
```

It will ask for a confirmation, with an "yes".

It will not delete your buckets or the data within.
