Create a new Github personal access token and note down the value.

Apply terraform
```
cd terraform
terraform init
TF_VAR_github_access_token=<value-from-before> terraform apply
```