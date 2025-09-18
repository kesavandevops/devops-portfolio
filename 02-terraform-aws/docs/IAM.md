# IAM Role & Policy (iam.tf)

This Terraform configuration provisions **IAM roles and policies** to securely allow EC2 instances to interact with AWS services like S3.

---

## Purpose

* Provide least-privilege access for EC2 to S3.
* Demonstrate IAM best practices by attaching roles instead of using static credentials.
* Ensure compliance and security in automation pipelines.

---

## Resources Created

* **aws\_iam\_role.ec2\_role**
  IAM role that EC2 instances can assume.
* **aws\_iam\_policy.ec2\_s3\_policy**
  Custom policy granting S3 access.
* **aws\_iam\_role\_policy\_attachment.ec2\_attach**
  Attaches the policy to the IAM role.
* **aws\_iam\_instance\_profile.ec2\_instance\_profile**
  Allows EC2 instances to use the IAM role.

---

## Key Configurations

* **Assume Role Policy** → Allows EC2 to assume this IAM role.
* **S3 Permissions** → Controlled via IAM policy JSON.
* **Instance Profile** → Automatically injected into EC2 at launch.

---

## Outputs

* **instance\_profile** → Used in EC2 resource to attach the IAM role.
