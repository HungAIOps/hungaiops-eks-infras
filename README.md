# HungAIOps EKS Infrastructure

Initialize Terraform with the environment-specific backend configuration:

```bash
terraform init -backend-config=backend-dev.hcl
```

## Static analysis

Install [TFLint](https://github.com/terraform-linters/tflint) and
[Checkov](https://www.checkov.io/) to run the same static checks locally:

```bash
terraform fmt -check -recursive
tflint --init
tflint --recursive
checkov -d . --framework terraform
```

GitHub Actions runs these checks for every pull request targeting `main`.
