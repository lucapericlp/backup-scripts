terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "usd_budget" {
  type = string
}

variable "alert_email" {
  type = string
}

resource "aws_kms_key" "glacier-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "archivals" {
  bucket = "deep-archivals"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssec" {
  bucket = aws_s3_bucket.archivals.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.glacier-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.archivals.id

  rule {
    id = "set-storage-class"

    filter {}

    status = "Enabled"

    transition {
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

resource "aws_budgets_budget" "archive" {
  name              = "budget-s3-monthly"
  budget_type       = "COST"
  limit_amount      = var.usd_budget
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2023-07-17_00:00"
  time_unit         = "MONTHLY"

  cost_filter {
    name = "Service"
    values = [
      "Amazon Simple Storage Service",
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
