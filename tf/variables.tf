variable "project" {}

variable "public_key_path" {
  description = "File containing SSH public key."
  default     = "~/.ssh/id_rsa.pub"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "batch_container_image" {
  default = "anibalsolon/cpac"
}

variable "batch_max_vcpus" {
  default = 5
}
