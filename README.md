# Terraform AWS Security Lab

This project is a simple lab to demonstrate how to use Terraform to create a simple AWS infrastructure with security best practices in mind. The infrastructure will consist of a VPC, a subnet, an EC2 instance and a s3 bucket with other supporting resources. The EC2 instance will have a role attached to it that will allow it to access the s3 bucket. We use a ec2 instance poliy to attech an IAM role which gives it access to a specifc s3 bucket. The infrastructure will be created using Terraform.


## Basic Setup for this project

The Lab assume that you have the following installed on your machine:  
`terraform`  
`aws cli`  
`git`  

### 1. Basic AWS account setup and requirements
The Lab also assumes that you have an AWS account and have the necessary permissions to create the resources in the lab and that you have the necessary credentials to access the account and your aws cli is configured with the necessary credentials.

When i tested this i used a new user account other then my aws root account with all access to all services. I created a new user with programmatic access and attached the AdministratorAccess policy to the user. I then used the access key and secret key to configure my aws cli.

### 2. Terraform setup and requirements

You will need to have Terraform installed on your machine. You can run
```bash
terraform --version
```
to check if you have terraform installed. 

Then assuming you have cloned this repository, you can run the following commands to initialize the project and install the necessary plugins.

```bash
terraform init
```

### 3. Deploying the infrastructure

Once you have the necessary setup and requirements, you can deploy the infrastructure by running the following command:

```bash
terraform apply
```

### 4. Removing Policy and Roles from AWS

To remove the ec2 policy and ec2 role created in the lab, you can run the following commands:

```bash
# Get the policy ARN from Terraform output
policy_arn=$(terraform output -raw policy_arn)

# Get the IAM role name from Terraform output
role_name=$(terraform output -raw ec2_role_name)

# Get the IAM instance profile name from Terraform output
instance_profile_name=$(terraform output -raw ec2_instance_profile_name)

# Detach the IAM policy from the IAM role using AWS CLI
aws iam detach-role-policy --policy-arn $policy_arn --role-name $role_name

# Remove the role from instance profile
aws iam remove-role-from-instance-profile --role-name $role_name --instance-profile-name $instance_profile_name

# Delete the instance profile from AWS
aws iam delete-instance-profile --instance-profile-name $instance_profile_name

# Delete the IAM role from AWS
aws iam delete-role --role-name $role_name
```

### 5. Destroying the infrastructure

To destroy the infrastructure, you can run the following command:

```bash
terraform destroy
```