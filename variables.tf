variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "lab-data-rushabh-patel-01"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "ubuntu_ami" {
  default = "ami-07d9b9ddc6cd8dd30" 
}

variable "vault_role_id" {}
variable "vault_secret_id" {}