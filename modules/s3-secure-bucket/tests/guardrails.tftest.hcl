mock_provider "aws" {}

variables {
  bucket_name = "securevault-test-bucket"
  tags        = { Owner = "tests" }
}

run "public_access_is_always_blocked" {
  command = plan

  assert {
    condition = (
      aws_s3_bucket_public_access_block.this.block_public_acls &&
      aws_s3_bucket_public_access_block.this.block_public_policy &&
      aws_s3_bucket_public_access_block.this.ignore_public_acls &&
      aws_s3_bucket_public_access_block.this.restrict_public_buckets
    )
    error_message = "All four public access block settings must be true."
  }
}

run "encryption_is_on_by_default" {
  command = plan

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      alltrue([for d in r.apply_server_side_encryption_by_default : d.sse_algorithm == "AES256"])
    ])
    error_message = "Without a KMS key the bucket must still use AES256 encryption."
  }
}

run "kms_key_switches_encryption_to_kms" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      alltrue([for d in r.apply_server_side_encryption_by_default : d.sse_algorithm == "aws:kms"])
    ])
    error_message = "Providing a KMS key must switch encryption to aws:kms."
  }
}

run "versioning_is_enabled_by_default" {
  command = plan

  assert {
    condition = alltrue([
      for v in aws_s3_bucket_versioning.this.versioning_configuration : v.status == "Enabled"
    ])
    error_message = "Versioning must be enabled by default."
  }
}
