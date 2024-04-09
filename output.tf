output "policy_arn" {
    value = aws_iam_policy.ec2_policy.arn
}

output "ec2_role_name" {
    value = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
    value = aws_iam_instance_profile.ec2_instance_profile.name
}

 
# output "db_username" {
#   value = data.vault_kv_secret_v2.rds.data.username
#   sensitive = true
# }