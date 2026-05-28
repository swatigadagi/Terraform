# Terraform AWS Infrastructure Project

# Introduction

This project is a complete AWS infrastructure built using Terraform.

Think of Terraform like a robot helper.
Instead of manually clicking buttons in AWS Console again and again, Terraform automatically creates everything using code.

This project creates:

* Networking (VPC)
* Security Groups
* EC2 Instance
* ECS Fargate Cluster
* Load Balancer
* RDS Aurora PostgreSQL Database
* ECR Repositories
* S3 Bucket
* IAM Roles & Policies
* CodeBuild CI/CD Pipeline

Everything is modular, reusable, and environment-based.

---

# Project Structure

Terraform/
 alb/
 codebuild/
 ec2/
 ecr/
 ecs/
 environments/
  prod/
 iam/
 rds/
 s3/
 vpc/
   README.md

This module creates the complete network setup.

Think of VPC like building a private city inside AWS.

Inside this city we create:

* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* VPC Endpoints

---

## Files Inside VPC

### `main.tf`

Main VPC creation happens here.

This creates:

* VPC CIDR block
* DNS support
* DNS hostnames

Example:

resource "aws_vpc" "this"

---

### `subnets.tf`

Creates:

* Public Subnets
* Private Subnets

Public subnet:

* internet accessible

Private subnet:

* secure internal communication

---

### `nat.tf`

Creates NAT Gateway.

Why?

Private servers sometimes need internet access for:

* updates
* package downloads
* docker image pull

But we still don’t want them publicly exposed.

NAT solves this.

---

### `routes.tf`

Controls traffic flow inside VPC.

Example:

* Public subnet → Internet Gateway
* Private subnet → NAT Gateway

Think of it like traffic roads.

---

### `security-groups.tf`

Creates firewall rules.

Controls:

* who can enter
* which port is open
* which service can communicate

Example:

* SSH access
* ECS access
* Database access

---

### `endpoints.tf`

Creates VPC endpoints.

This allows AWS services like:

* S3
* ECR
* CloudWatch

to communicate privately without using internet.

More secure and cost optimized.

---

### `outputs.tf`

Exports useful values like:

* VPC ID
* Subnet IDs
* Security Group IDs

Other modules use these outputs.

---

### `variables.tf`

Stores reusable input variables.

Example:

* project name
* environment
* CIDR ranges

---

# S3 Module

Folder:

/s3

Creates frontend storage bucket.

This bucket stores:

* frontend static files
* build artifacts

Example:

* HTML
* CSS
* JS

---

## Files

### `main.tf`

Creates S3 bucket.

Example:

resource "aws_s3_bucket" "this"

---

### `outputs.tf`

Exports:

* bucket name
* bucket ARN


### `variables.tf`

Stores:

* project
* environment
* bucket naming inputs


# RDS Module

Folder:

/rds

Creates Aurora PostgreSQL database cluster.

This is the backend database.

---

## What it creates

* DB subnet group
* Aurora Cluster
* DB Instances
* Security Groups

---

## Files

### `main.tf`

Main database creation.

Creates:

* Aurora PostgreSQL
* DB subnet group
* database security group

---

### `outputs.tf`

Exports:

* database endpoint
* cluster endpoint
* security group ID

---

### `variables.tf`

Stores:

* DB username
* DB password
* subnet IDs
* VPC ID

---

# IAM Module

Folder:

IAM controls permissions.

Think of IAM like identity cards and access permissions.

---

## Files

### `main.tf`

Creates common IAM resources.

---

### `ecs.tf`

Creates ECS execution role.

Allows ECS tasks to:

* pull images
* write logs

---

### `codebuild.tf`

Creates CodeBuild IAM role.

Allows CodeBuild to:

* build images
* push to ECR
* access S3
* deploy ECS

---

### `workers.tf`

Creates worker related IAM roles.

---

### `policies.tf`

Custom IAM policies are created here.

---

### `outputs.tf`

Exports:

* IAM role ARNs
* policy ARNs

---

### `variables.tf`

Stores:

* role names
* project names

---

# ECS Module

Folder:

/ecs

This module runs containerized applications.

Uses:

* ECS Fargate
* Docker Containers

No server management needed.

AWS manages the infrastructure automatically.

---

## Files

### `main.tf`

Creates ECS cluster.

---

### `task-definition.tf`

Defines:

* docker image
* CPU
* memory
* container port
* environment variables

This is like a recipe for running containers.

---

### `service.tf`

Runs ECS services.

Maintains:

* desired container count
* auto recovery
* deployment updates

---

### `autoscaling.tf`

Automatically increases/decreases containers based on load.

Example:

* high CPU → add more containers

---

### `outputs.tf`

Exports:

* ECS cluster name
* service name

---

### `variables.tf`

Stores:

* image URLs
* ports
* cluster names

---

# EC2 Module

Folder:

/ec2

Creates EC2 instance.

Used for:

* administration
* debugging
* bastion access

---

## What it creates

* EC2 Security Group
* IAM Role
* Instance Profile
* Ubuntu EC2 instance

---

## Files

### `main.tf`

Creates:

* EC2 instance
* IAM role
* security group

---

### `variables.tf`

Stores:

* instance type
* subnet IDs
* VPC ID

---

# ECR Module

Folder:

/ecr

Creates Docker image repositories.

Stores backend container images.

---

## Files

### `main.tf`

Creates ECR repositories.

---

### `lifecycle.tf`

Automatically deletes old unused images.

Helps reduce storage cost.

---

### `outputs.tf`

Exports:

* ECR repository URL

---

### `variables.tf`

Stores:

* repository names

---

# CodeBuild Module

Folder:

/codebuild

Used for CI/CD automation.

Automatically:

* pulls source code
* builds application
* pushes docker image
* uploads artifacts

---

## Files

### `main.tf`

Creates:

* frontend CodeBuild project
* backend CodeBuild project
* IAM role for CodeBuild

Uses:

* Bitbucket repositories
* buildspec YAML files

---

### `variables.tf`

Stores:

* environment
* bucket names
* build image
* compute type

---

# ALB Module

Folder:

/alb

Creates Application Load Balancer.

ALB distributes incoming traffic.

---

## What it creates

* ALB
* Target Groups
* Listeners
* Security Groups

---

## Files

### `main.tf`

Creates ALB.

---

### `listener.tf`

Controls:

* HTTP routing
* HTTPS routing

---

### `target-group.tf`

Connects ALB with ECS containers.

---

### `security-groups.tf`

Controls ALB traffic.

---

### `outputs.tf`

Exports:

* ALB DNS URL

---

# Environment Folder

Folder:

/environments/prod

This is the actual deployment entry point.

This module calls all other modules together.

Like:

* VPC
* ECS
* ALB
* RDS
* ECR
* S3
* IAM
* EC2
* CodeBuild

---

# Terraform Commands

## Initialize

terraform init

---

## Validate

terraform validate

---

## Plan

terraform plan

---

## Apply

terraform apply -auto-approve

---

## Destroy

terraform destroy -auto-approve

---

# Infrastructure Flow

User
  ↓
ALB
  ↓
ECS Fargate Containers
  ↓
Aurora PostgreSQL

Frontend:

* stored in S3

Backend Images:

* stored in ECR

CI/CD:

* handled using CodeBuild

---

# Technologies Used

* Terraform
* AWS VPC
* ECS Fargate
* Aurora PostgreSQL
* EC2
* ECR
* S3
* ALB
* IAM
* CodeBuild
* Bitbucket

---

# Goal of This Project

This project demonstrates a production-style AWS infrastructure using Infrastructure as Code (IaC).

Focus areas:

* modular Terraform architecture
* reusable environments
* scalable container deployment
* secure networking
* automation
* CI/CD pipelines

---

