vault server -dev -dev-listen-address="0.0.0.0:8200"

export VAULT_ADDR=http://localhost:8200/
export VAULT_TOKEN=<token>

vault auth enable approle

vault policy write terraform - <<EOF
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform

vault read auth/approle/role/terraform/role-id
vault write -f auth/approle/role/terraform/secret-id


# enable kv secret engine at kv path

vault secrets enable -path=kv kv
vault kv put kv/rds username=rushabh password=Rushabh@123

vault kv get kv/rds


# create a json file

echo '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::lab-data-rushabh-patel-01",
        "arn:aws:s3:::lab-data-rushabh-patel-01/*"
      ]
    }
  ]
}' > iam.json

vault write kv/iam policy=@iam.json

vault kv get kv/iam