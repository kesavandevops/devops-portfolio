# RDS Database (rds.tf)

This Terraform configuration provisions an **Amazon RDS MySQL database instance** for persistent application data.

---

## Purpose

* Provide a managed relational database with backups and availability.
* Demonstrate VPC + security group + DB subnet group integration.
* Securely store credentials using variables and avoid hardcoding.

---

## Resources Created

* **aws\_security\_group.rds\_sg**
  Security group allowing inbound MySQL (3306) only from EC2 SG.
* **aws\_db\_subnet\_group.rds\_subnet\_group**
  Ensures RDS is deployed in multiple subnets (high availability).
* **aws\_db\_instance.rds\_instance**
  Main RDS MySQL instance with defined size, storage, and engine.

---

## Key Configurations

* **Engine** → MySQL 8.0
* **Storage** → 20 GB (gp2, expandable)
* **Credentials** → Taken from variables (`db_username`, `db_password`).
* **Networking** → Isolated inside VPC, accessible only from EC2 SG.

---

## Outputs

* **rds\_endpoint** → DNS name for database connections.
* **rds\_name** → The created DB instance identifier.

---

## Usage

From the EC2 instance (with MySQL client installed), connect using:

```bash
mysql -h <RDS_ENDPOINT> -u <DB_USER> -p
```
