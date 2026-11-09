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
  # Accepted risks (see the findings register in the PR description):
  # checkov:skip=CKV_AWS_18: Access logging needs a second dedicated log bucket; CloudTrail already records API access to this lab bucket. Revisit before storing production state.
  # checkov:skip=CKV_AWS_144: Single-region class lab; cross-region replication doubles storage cost for disaster recovery we do not need. Revisit before storing production state.
  # checkov:skip=CKV2_AWS_62: No consumer exists for S3 event notifications here, so enabling them adds no security value.

  # Bucket names must be globally unique across all of AWS
  bucket = "shina-tf-state-2026"

  tags = {
    Environment = "Testing"
    ManagedBy   = "DevOps Class"
  }
}

# Terraform state can contain secrets: never let this bucket become public (CKV2_AWS_6)
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Keep previous state versions so a bad apply or corrupted state can be rolled back (CKV_AWS_21)
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt every object at rest with KMS (AWS-managed key) by default (CKV_AWS_145)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Versioning keeps every old copy; expire them so storage does not grow forever (CKV2_AWS_61)
resource "aws_s3_bucket_lifecycle_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.tf_state]
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
