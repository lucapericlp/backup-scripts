terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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
