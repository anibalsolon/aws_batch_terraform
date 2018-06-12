# Run C-PAC in AWS Batch

This set of scripts and Terraform definitions will help you to seamlessly build up your own infrastructure on AWS, run preprocessing of your subjects, and turn off the infrastructure.

## Pre-requisites

First, you need to install and configurate the AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
And authenticate with your access and secret key: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

Now, you need to install Terraform: https://www.terraform.io/intro/getting-started/install.html

You are ready to start preprocessing!

## Setting up your data

In order to preprocess your neuroimages on AWS, the data must be on a S3 bucket.

## Building up the infrastructure

Please check your current limits of running instances on AWS: https://console.aws.amazon.com/ec2/v2/home#Limits:
You can open a support ticket on AWS to raise these limits.


