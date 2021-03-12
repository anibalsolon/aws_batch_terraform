# Running C-PAC in AWS Batch

This set of scripts and Terraform definitions will help you to seamlessly build up your own infrastructure on AWS, run preprocessing of your subjects, and turn off the infrastructure.
## Pre-requisites

First, you need to install and configurate the AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/installing.html

And authenticate with your access and secret key: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

Now, you need to install Terraform: https://www.terraform.io/intro/getting-started/install.html

You are ready to start preprocessing!

## Setting up your data

In order to preprocess your neuroimages on AWS, the data must be on a S3 bucket, along with the data config and pipeline config YAML file.

The AWS user that you use to configure AWS CLI must have access to the S3 bucket.

## Building up the infrastructure

Please check your current limits of running instances on AWS: https://console.aws.amazon.com/ec2/v2/home#Limits:
You can open a support ticket on AWS to raise these limits.

To build the infrastructure, you must run:
```bash
./generate_infra.sh my-project-cool-name --max_cpu 16 
```

`max_cpu` indicates the maximum of vCPUs will be available to execute the jobs.
Having the limit of 20 cpus, and executing 14 jobs that use 4 cpus each, only 5 jobs are executed concurrently and the
other 9 jobs get queued.

Other options are:
`--aws_region`: to specity to which AWS region to create the resources.
`--public_key_path`: to specify the public SSH key to use in the Batch instances. By default, it uses `~/.ssh/id_rsa.pub`.

The command will show which AWS resources are going to be created. You need to confirm it with an "yes".

After some time, your infrastructure will be ready to run your first job.

## Preprocessing subjects

To start your preprocessing task, you may run the following command, replacing `--pipeline_file` and `--data_config_file` 
to the config files in your bucket, and `--output_dir` with the bucket path for outputting derivatives from the pipeline.
You can also point to a S3 BIDS directory to use as input data, instead of provifing a data config YAML file.
The pipeline YAML file is optional, using the default pipeline when it is not provided.

```bash
./process_subjects.sh \
    my-project-cool-name \
    s3://fcp-indi/data/Projects/ABIDE/RawDataBIDS/NYU/ \  # BIDS directory
    --n_cpus 4 \
    --mem_gb 8 \
    --output_dir s3://cnl-cpac-batch/output -- 0051159
```

```bash
./process_subjects.sh \
    my-project-cool-name \
    --pipeline_file s3://my-bucket/pipeline_config.yaml \
    --data_config_file s3://my-data-bucket/data_config.yaml \
    --output_dir s3://my-output-bucket/cpac_output -- 0000001 0000002 0000003 0000004
```

After the double dashes, a list of subject IDs must be provided.

Other options are:
`--n_cpus`: to specity the number of CPUs to allocate for each job.
`--mem_gb`: to specify the amount of memory used for each job.

It will schedule a job for each subject, so AWS Batch manager will parallelise all subjects pipelines.

The output will be uploaded to the informed bucket.

## Destroying your infrastructure

After your analysis finishes, and you do not need the infrastructure anymore, you can safely destroy it.

```bash
./destroy_infra.sh \
    my-project-cool-name
```

It will ask for a confirmation, with an "yes".

It will not delete your buckets or the data within it.
