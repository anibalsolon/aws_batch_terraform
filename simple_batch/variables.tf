variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "public_key_path" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "batch_max_vcpus" {
  default = 5
}

variable "batch_instance_types" {
  type    = "list"
  default = ["c4.large"]
}

variable "batch_container_image" {
  default = "bids/cpac"
}

variable "batch_container_memory" {
  default = 2048
}

variable "batch_container_cpu" {
  default = 2
}

variable "bucket" {}
