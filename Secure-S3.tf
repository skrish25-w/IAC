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

  # Cross-Region Replication (if required, configure replication accordingly)
  replication_configuration {
    role = aws_iam_role.replication_role.arn
    rules {
      id     = "ReplicationRule"
      status = "Enabled"

      destination {
        bucket        = "arn:aws:s3:::replica-bucket"
        storage_class = "STANDARD"
      }

      filter {
        prefix = "logs/"
      }
    }
  }

  # Event Notification Configuration
  event_notification {
    event_types = ["s3:ObjectCreated:*"]
    lambda_function {
      lambda_function_arn = aws_lambda_function.s3_event_processor.arn
    }
  }
}

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

  # Cross-Region Replication (if required, configure replication accordingly)
  replication_configuration {
    role = aws_iam_role.replication_role.arn
    rules {
      id     = "ReplicationRule"
      status = "Enabled"

      destination {
        bucket        = "arn:aws:s3:::replica-bucket"
        storage_class = "STANDARD"
      }

      filter {
        prefix = "logs/"
      }
    }
  }

  # Event Notification Configuration
  event_notification {
    event_types = ["s3:ObjectCreated:*"]
    lambda_function {
      lambda_function_arn = aws_lambda_function.s3_event_processor.arn
    }
  }
}

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

  # Cross-Region Replication (if required, configure replication accordingly)
  replication_configuration {
    role = aws_iam_role.replication_role.arn
    rules {
      id     = "ReplicationRule"
      status = "Enabled"

      destination {
        bucket        = "arn:aws:s3:::replica-bucket"
        storage_class = "STANDARD"
      }

      filter {
        prefix = "logs/"
      }
    }
  }

  # Event Notification Configuration
  event_notification {
    event_types = ["s3:ObjectCreated:*"]
    lambda_function {
      lambda_function_arn = aws_lambda_function.s3_event_processor.arn
    }
  }
}

resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "s3_event_processor" {
  filename      = "function.zip"
  function_name = "s3-event-processor"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda-execution-policy"
  description = "IAM policy for Lambda execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::secureiac/*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_exec_policy_attachment" {
  name       = "lambda-execution-policy-attachment"
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
  roles      = [aws_iam_role.lambda_exec_role.name]
}
