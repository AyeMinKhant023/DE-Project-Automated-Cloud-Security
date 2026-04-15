# Automated Cloud Security

**Course:** 977-302 Digital Engineering Project I  
**Author:** Aye Min Khant (6630613023)

## Project Overview

This project uses **Terraform** to automate the deployment of a secure, 3-tier architecture on AWS. The goal is to eliminate "ClickOps" and replace it with **Infrastructure-as-Code (IaC)**.

## The Architecture

- **VPC:** Custom network with Public and Private subnets across 2 Availability Zones.
- **Security:** Zero Trust principles using Security Group interlinking.
- **Workloads:** EC2 Web Server (Private) and RDS MySQL Database (Private).
- **Egress:** NAT Gateway for secure outbound updates.

## Tools Used

- Terraform (IaC)
- AWS (Cloud Provider)
- Git/GitHub (Version Control)
