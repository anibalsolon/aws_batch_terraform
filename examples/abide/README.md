# ABIDE example

In order to run this example, upload `data_config.yaml` and `pipeline_config.yaml` files to your S3 bucket, and run the following commands:

Generate the infrastructure to preprocess the ABIDE dataset.

```bash
./generate_infra.sh cpac-abide --max_cpu 32 --instance_type c4.4xlarge
```

Schedule the preprocessing for some ABIDE subjects. You may change `my-bucket` to your actual bucket.

```bash
./process_subjects.sh \
    cpac-abide \
    --pipeline_file s3://my-bucket/pipeline_config.yaml \
    --data_config_file s3://my-bucket/data_config.yaml \
    --output_dir s3://my-bucket/output -- 0050642 0050646 0050647 0050649 0050653 0050654 0050656 0050659 0050660
```