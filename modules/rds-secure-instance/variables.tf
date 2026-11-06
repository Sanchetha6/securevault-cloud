variable "identifier" {
  description = "Unique name for the RDS instance."
  type        = string
}

variable "engine" {
  description = "Database engine. Only engines that support IAM database authentication are allowed."
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "engine must be postgres or mysql."
  }
}

variable "engine_version" {
  description = "Engine version. Leave null to let AWS pick the current default."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Instance size."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "username" {
  description = "Master username. The password is generated and stored by AWS Secrets Manager, never in code or state."
  type        = string
  default     = "dbadmin"
}

variable "db_subnet_group_name" {
  description = "Existing DB subnet group (private subnets). Required, so the database always lands in a network you chose."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security groups for the database, typically from the security-group module. Must not be empty."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key for encryption. If null, the AWS-managed RDS key is used (still encrypted)."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Days to keep automated backups. Must be at least 7."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 7
    error_message = "backup_retention_period must be at least 7 days. Backups cannot be switched off or shortened below 7 in this module."
  }
}

variable "multi_az" {
  description = "Run a standby in a second availability zone."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Block accidental deletion. Set false only in throwaway sandboxes."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on delete. Keep false outside sandboxes."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply, typically the output of the mandatory-tags module."
  type        = map(string)
}
