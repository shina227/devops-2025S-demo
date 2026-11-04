# This block tells Terraform we need the 'aws' provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Uses the credentials you set up with 'aws configure'
provider "aws" {
  region = "us-east-1"
}

# An S3 bucket, e.g. for storing Terraform state
resource "aws_s3_bucket" "tf_state" {
  # Bucket names must be globally unique across all of AWS
  bucket = "shina-tf-state-2026"

  tags = {
    Environment = "Testing"
    ManagedBy   = "DevOps Class"
  }
}

# A resource group, the AWS equivalent of an Azure resource group.
# It groups every resource tagged ManagedBy = "DevOps Class".
resource "aws_resourcegroups_group" "rg" {
  name        = "shina-rg"
  description = "Resource group created with Terraform for the DevOps class lab"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["DevOps Class"]
        }
      ]
    })
  }

  tags = {
    Environment = "Testing"
    ManagedBy   = "DevOps Class"
  }
}

# Prints the names after they're created
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.tf_state.bucket
}


output "resource_group_name" {
  description = "The name of the resource group"
  value       = aws_resourcegroups_group.rg.name
}
