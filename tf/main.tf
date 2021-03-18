provider "aws" {
  region = var.aws_region
}

# Networking

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "default" {
  name   = "batch_security_group"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM policies

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name = "ecs_instance_role_policy"
  role = aws_iam_role.ecs_instance_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::*"]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "aws_batch_service_role" {
  name = "aws_batch_service_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "batch.amazonaws.com"
        }
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# Batch

resource "aws_key_pair" "auth" {
  key_name   = var.project
  public_key = file(var.public_key_path)
}

resource "aws_launch_template" "default" {
  name_prefix = var.project

  user_data = filebase64("${path.module}/userdata.sh")

  block_device_mappings {
    device_name = "/dev/xvdcz"
    ebs {
      volume_size = 200
    }
  }
}

resource "aws_batch_compute_environment" "default" {
  compute_environment_name = var.project

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    instance_type = ["optimal"]

    launch_template {
      launch_template_id = aws_launch_template.default.id
    }

    ec2_key_pair = aws_key_pair.auth.id

    min_vcpus     = 0
    desired_vcpus = 0
    max_vcpus     = var.batch_max_vcpus

    security_group_ids = [
      aws_security_group.default.id
    ]

    subnets = [
      aws_subnet.default.id
    ]

    type = "EC2"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]
}

resource "aws_batch_job_queue" "default" {
  name                 = var.project
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.default.arn]
}

resource "aws_batch_job_definition" "default" {
  name = var.project
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
{
    "image": "${var.batch_container_image}",
    "memory": 8192,
    "vcpus": 4
}
CONTAINER_PROPERTIES
}
