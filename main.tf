terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  # token = "hvs.0D32cOFyZVXX9wVM8YGUhuwx"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}

// we have screate in kv v2 store in vault under rds
data "vault_kv_secret_v2" "rds" {
  mount = "kv"
  name  = "rds"
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Allow EC2 to access S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.bucket_name}", "arn:aws:s3:::${var.bucket_name}/*"]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

// create a bucket in S3
resource "aws_s3_bucket" "lab_bucket" {
  bucket = var.bucket_name
  tags = {
    Env = "lab"
  }
}

// create a ssh key pair
resource "aws_key_pair" "lab_key" {
  key_name   = "lab-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

// VPC and Subnet
resource "aws_vpc" "lab_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "lab_subnet" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = var.subnet_cidr
}

// create a security group
resource "aws_security_group" "lab_sg" {
  name        = "lab-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// crate a ubuntu ec2 instance
resource "aws_instance" "lab_instance" {
  ami                  = var.ubuntu_ami
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.lab_key.key_name
  subnet_id            = aws_subnet.lab_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "lab-instance"
  }
}

// add a RDS instance

resource "aws_db_instance" "lab_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  db_name                = "lab"
  username               = data.vault_kv_secret_v2.rds.data.username
  password               = data.vault_kv_secret_v2.rds.data.password
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
}
