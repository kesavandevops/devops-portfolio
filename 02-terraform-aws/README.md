# Terraform AWS — Infrastructure as Code

This project demonstrates provisioning a small, reusable AWS infrastructure using **Terraform**.  
It creates a VPC, a public subnet, internet gateway, route table, a security group, and an EC2 instance with Nginx installed via user-data.

> **Important:** This is for learning/demo purposes. Destroy resources after usage to avoid charges.

---

## Prerequisites

- Terraform installed (v1.2+ recommended)
- AWS CLI configured with credentials that have permissions to create VPCs, EC2, IAM resources, etc.
- (Optional) An EC2 keypair in the target region if you want SSH access

---

## Files

- `provider.tf` — Terraform provider and required providers
- `variables.tf` — Input variables and defaults
- `main.tf` — Main resource definitions: VPC, subnet, SG, EC2
- `outputs.tf` — Useful outputs (instance IP, IDs)
- `terraform.tfvars` — Default variable values (edit before apply)

---

## Quickstart — deploy

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan -var-file="terraform.tfvars"
```

3. Apply (creates resources):
```bash
terraform apply -var-file="terraform.tfvars"
```

4. After apply completes, view outputs:
```bash
terraform output
```

Open the instance public IP in a browser to see the Nginx page created by user-data.

---

## Destroy — cleanup to avoid charges

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## Notes & Best Practices

- For team projects, use a remote backend (S3 + DynamoDB) for state locking.  
- Never commit sensitive values (like AWS keys) into the repo. Use `terraform.tfvars` locally or CI secrets.  
- Use modules for larger infra and to promote reusability.
