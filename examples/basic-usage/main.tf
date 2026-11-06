terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "tags" {
  source = "../../modules/mandatory-tags"

  owner       = "platform-team@example.com"
  environment = "dev"
  cost_center = "CC-1234"

  data_classification = "confidential"
  extra_tags = {
    Project = "secure-modules-demo"
  }
}

module "app_data_bucket" {
  source = "../../modules/s3-secure-bucket"

  bucket_name       = "sancheta-securevault-2026"
  enable_versioning = true
  tags              = module.tags.tags
}

module "web_sg" {
  source = "../../modules/security-group"

  name        = "web-tier-sg"
  description = "Security group for public-facing web tier"
  vpc_id      = "vpc-0595872216d39ef62" # replace with a real VPC id

  # Public HTTPS is allowed because 443 is in allow_public_ingress_ports.
  # SSH is scoped to a specific office/VPN CIDR — 0.0.0.0/0 on port 22
  # would fail the module's built-in check.
  ingress_rules = [
    {
      description = "HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH from office VPN only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
    }
  ]

  allow_public_ingress_ports = [443]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = module.tags.tags
}
