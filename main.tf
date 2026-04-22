## Managed By : ASTechMind
# Description : This Script is used to create S3.
## Copyright @ ASTechMind. All Right Reserved.

resource "aws_s3_bucket" "this" {
  count = var.create_bucket ? 1 : 0

  bucket        = var.name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  count = var.create_bucket && var.acl != null && var.acl != "" ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create_bucket && var.encryption_enabled ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_master_key_id != "" ? var.kms_master_key_id : null
    }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.create_bucket && var.website_hosting_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  index_document {
    suffix = var.website_index
  }

  error_document {
    key = var.website_error
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count = var.create_bucket && var.cors_rule_inputs != null ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  dynamic "cors_rule" {
    for_each = var.cors_rule_inputs == null ? [] : var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = var.create_bucket && var.bucket_logging_enabled ? 1 : 0

  bucket        = aws_s3_bucket.this[0].id
  target_bucket = var.target_bucket
  target_prefix = var.target_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.create_bucket && (var.lifecycle_infrequent_storage_transition_enabled || var.lifecycle_glacier_transition_enabled || var.lifecycle_expiration_enabled) ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  dynamic "rule" {
    for_each = var.lifecycle_infrequent_storage_transition_enabled ? [1] : []
    content {
      id     = "transition-to-infrequent-access-storage"
      status = "Enabled"
      filter {
        prefix = var.lifecycle_infrequent_storage_object_prefix
      }
      transition {
        days          = var.lifecycle_days_to_infrequent_storage_transition
        storage_class = "STANDARD_IA"
      }
    }
  }

  dynamic "rule" {
    for_each = var.lifecycle_glacier_transition_enabled ? [1] : []
    content {
      id     = "transition-to-glacier"
      status = "Enabled"
      filter {
        prefix = var.lifecycle_glacier_object_prefix
      }
      transition {
        days          = var.lifecycle_days_to_glacier_transition
        storage_class = "GLACIER"
      }
    }
  }

  dynamic "rule" {
    for_each = var.lifecycle_expiration_enabled ? [1] : []
    content {
      id     = "expire-objects"
      status = "Enabled"
      filter {
        prefix = var.lifecycle_expiration_object_prefix
      }
      expiration {
        days = var.lifecycle_days_to_expiration
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.create_bucket && var.bucket_policy && var.aws_iam_policy_document != "" ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  policy = var.aws_iam_policy_document

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}
