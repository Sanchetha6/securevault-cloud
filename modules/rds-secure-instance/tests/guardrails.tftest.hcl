mock_provider "aws" {}

variables {
  identifier             = "securevault-test-db"
  db_name                = "appdb"
  db_subnet_group_name   = "default"
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  tags                   = { Owner = "tests" }
}

run "secure_defaults_are_applied" {
  command = plan

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "Storage must always be encrypted."
  }

  assert {
    condition     = aws_db_instance.this.publicly_accessible == false
    error_message = "The database must never be publicly accessible."
  }

  assert {
    condition     = aws_db_instance.this.backup_retention_period == 7
    error_message = "Default backup retention must be 7 days."
  }

  assert {
    condition     = aws_db_instance.this.iam_database_authentication_enabled == true
    error_message = "IAM database authentication must be on."
  }

  assert {
    condition     = aws_db_instance.this.manage_master_user_password == true
    error_message = "The password must be managed by Secrets Manager."
  }
}

run "short_backup_retention_is_rejected" {
  command = plan

  variables {
    backup_retention_period = 1
  }

  expect_failures = [var.backup_retention_period]
}

run "unsupported_engine_is_rejected" {
  command = plan

  variables {
    engine = "oracle-ee"
  }

  expect_failures = [var.engine]
}

run "empty_security_group_list_is_rejected" {
  command = plan

  variables {
    vpc_security_group_ids = []
  }

  expect_failures = [aws_db_instance.this]
}
