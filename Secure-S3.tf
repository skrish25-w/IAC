provider "aws" {
  region = "ap-south-1"
}

# S3 Audit Logging Bucket
resource "aws_s3_bucket" "audit_logging" {
  bucket = "secureiac-audit-logs"

  # Public Access Block
  public_access_block {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }

  # Versioning
  versioning {
    enabled = true
  }

  # Logging Configuration
  logging {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "audit-logs/"
  }

  # Ownership Controls
  object_ownership {
    rule = "BucketOwnerEnforced"
  }

  # Bucket Policy (to prevent lockout)
  bucket_policy {
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action    = "s3:ListBucket"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "arn:aws:s3:::${aws_s3_bucket.audit_logging.bucket}"
          Condition = {
            IpAddress = {
              "aws:SourceIp" = "0.0.0.0/0"
            }
          }
        },
        {
          Action    = "s3:GetObject"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "arn:aws:s3:::${aws_s3_bucket.audit_logging.bucket}/*"
        }
      ]
    })
  }

  # Prevent Destroy
  lifecycle {
    prevent_destroy = true
  }
}

# S3 Logging Bucket
resource "aws_s3_bucket" "logging" {
  bucket = "secureiac-logs"

  # Public Access Block
  public_access_block {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }

  # Versioning
  versioning {
    enabled = true
  }

  # Logging Configuration
  logging {
    target_bucket = aws_s3_bucket.audit_logging.bucket
    target_prefix = "audit-logs/"
  }

  # Ownership Controls
  object_ownership {
    rule = "BucketOwnerEnforced"
  }

  # Prevent Destroy
  lifecycle {
    prevent_destroy = true
  }
}

# S3 Secure IAC Bucket
resource "aws_s3_bucket" "secure_iac" {
  bucket = "secureiac"

  # Public Access Block
  public_access_block {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }

  # Versioning
  versioning {
    enabled = true
  }

  # Encryption (AES256)
  encryption {
    server_side_encryption_configuration {
      server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Logging Configuration
  logging {
    target_bucket = aws_s3_bucket.logging.bucket
    target_prefix = "logs/"
  }

  # Ownership Controls
  object_ownership {
    rule = "BucketOwnerEnforced"
  }

  # Prevent Destroy
  lifecycle {
    prevent_destroy = true
  }
}

# Outputs
output "SecureIACBucketName" {
  description = "Name of the secure S3 bucket"
  value       = aws_s3_bucket.secure_iac.bucket
}

output "LoggingBucketName" {
  description = "Name of the logging S3 bucket"
  value       = aws_s3_bucket.logging.bucket
}

output "AuditLoggingBucketName" {
  description = "Name of the audit logging S3 bucket"
  value       = aws_s3_bucket.audit_logging.bucket
}
