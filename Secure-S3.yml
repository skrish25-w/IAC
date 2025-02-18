provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "audit_logging" {
  bucket = "secureiac-audit-logs"

  public_access_block_configuration {
    block_public_acls        = true
    ignore_public_acls       = true
    block_public_policy      = true
    restrict_public_buckets  = true
  }

  ownership_controls {
    rules {
      object_ownership = "BucketOwnerEnforced"
    }
  }

  versioning {
    enabled = true
  }

  metadata = {
    checkov = jsonencode({
      skip = [
        {
          id      = "CKV_AWS_18"
          comment = "AuditLoggingBucket is a designated log storage bucket and does not need access logging."
        }
      ]
    })
  }
}

resource "aws_s3_bucket" "logging" {
  bucket = "secureiac-logs"

  public_access_block_configuration {
    block_public_acls        = true
    ignore_public_acls       = true
    block_public_policy      = true
    restrict_public_buckets  = true
  }

  ownership_controls {
    rules {
      object_ownership = "BucketOwnerEnforced"
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.audit_logging.bucket
    prefix        = "audit-logs/"
  }
}

resource "aws_s3_bucket" "secure_iac" {
  bucket = "secureiac"

  public_access_block_configuration {
    block_public_acls        = true
    ignore_public_acls       = true
    block_public_policy      = true
    restrict_public_buckets  = true
  }

  logging {
    target_bucket = aws_s3_bucket.logging.bucket
    prefix        = "logs/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  ownership_controls {
    rules {
      object_ownership = "BucketOwnerEnforced"
    }
  }
}

output "secure_iac_bucket_name" {
  description = "Name of the secure S3 bucket"
  value       = aws_s3_bucket.secure_iac.bucket
}

output "logging_bucket_name" {
  description = "Name of the logging S3 bucket"
  value       = aws_s3_bucket.logging.bucket
}

output "audit_logging_bucket_name" {
  description = "Name of the audit logging S3 bucket"
  value       = aws_s3_bucket.audit_logging.bucket
}
