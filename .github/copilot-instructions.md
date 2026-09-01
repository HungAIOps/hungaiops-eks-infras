# Copilot Instructions

## Workspace Overview
This repository is a Terraform monorepo used to provision the test environment
infrastructure for the HungAIOps project. It provisions the AWS networking and
EKS cluster and other infrastructure components.

Project structure:

```
.
├── backend.tf                     # Remote state backend config (e.g. S3 + DynamoDB lock table)
├── variable.tf                   # Root-level input variable declarations
├── output.tf                     # Root-level outputs (e.g. instance IPs, cluster endpoint)
├── main.tf                        # Root module composition — wires child modules together
├── terraform.tfvars.example       # Example var file, no secrets, committed
├── modules/
│   ├── network/                   # VPC, subnets, route tables, IGW/NAT
│   ├── eks/                       # EKS cluster and node groups
│   └── ...                        # Other modules as needed
├── scripts/                        # Helper scripts (e.g. state migration, plan diff formatting)
└── README.md                       # Setup, usage, and Jenkins job integration notes
```

## General Terraform Coding Rules
- Every module should have at least: `main.tf`, `variable.tf`, `outputs.tf`
- Define variables in variable.tf for values that vary by environment or are reused (e.g. instance type, region, AMI ID, K8s version, CIDR ranges), with sane default values where appropriate. Hardcoding is fine for truly fixed, one-off values.
- Use consistent, descriptive resource labels, or "this" for the common single-resource-per-type convention. Use snake_case for resource, variable, and output names.
- Declare a type for every variable. Add a description for every variable and output. Use validation blocks for inputs with known constraints.
- Prefer for_each over count for collections of named/distinguishable resources; reserve count for simple conditional or positional resources.
- Look up AMIs, AZs, VPC IDs, etc. via data blocks rather than hardcoding IDs.
- Use locals {} to name expressions that are reused or improve readability.
- Do not use emojis or icon characters in comments, docstrings, or commit messages.
- Keep comments short and only add them when the code is not self-explanatory; explain why, not what.

## Secrets & Security
- Never hardcode AWS credentials, tokens, or private key material in `.tf` or `.tfvars` files.
- Mark sensitive variables and outputs with sensitive = true. Never hardcode credentials, tokens, or keys in .tf/.tfvars files.

## Testing Requirements
- All modules and root configuration must pass `terraform fmt -check -recursive`, `terraform validate`, and `tflint` before being considered complete:
  + Format checking command: `terraform fmt -check -recursive`
  + Validation command: `terraform validate`
  + Lint checking command: `tflint --recursive`
- DO NOT test or run any terraform commands (such as terraform plan) unless explicitly asked in prompt.
- DO NOT write Terraform unit/integration tests (e.g. Terratest, `.tftest.hcl` files) unless explicitly asked in prompt.

## LLM token usage rules
- Save and use input and output LLM token efficiently as much as possible.