resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  db_name           = var.db_name

  # --- Credentials: AWS creates and rotates the password in Secrets Manager.
  # No password variable exists, so one can never be hardcoded or end up in state.
  username                    = var.username
  manage_master_user_password = true

  # --- Network: never public. There is no variable to change this.
  publicly_accessible    = false
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # --- Encryption at rest: always on, no variable to turn it off.
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  # --- Access and resilience
  iam_database_authentication_enabled = true
  backup_retention_period             = var.backup_retention_period
  multi_az                            = var.multi_az
  auto_minor_version_upgrade          = true
  copy_tags_to_snapshot               = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final"

  tags = var.tags

  lifecycle {
    # Hard error (unlike a check block): the database must sit behind at
    # least one security group that the caller chose on purpose.
    precondition {
      condition     = length(var.vpc_security_group_ids) > 0
      error_message = "vpc_security_group_ids must contain at least one security group. Do not rely on the VPC default security group."
    }
  }
}
