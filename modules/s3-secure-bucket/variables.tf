variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption. If null, an S3-managed AES256 key is used instead (still encrypted, just not customer-managed)."
  type        = string
  default     = null
}

variable "enable_versioning" {
  description = "Enable object versioning (recommended for anything holding data you can't afford to lose or that needs ransomware/accidental-delete recovery)."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow `terraform destroy` to delete a non-empty bucket. Keep false in prod."
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration_days" {
  description = "Days to retain noncurrent object versions before expiring them. Set to 0 to disable lifecycle expiration."
  type        = number
  default     = 90
}

variable "enable_access_logging" {
  description = "Whether to write S3 server access logs to a target bucket."
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Bucket to receive access logs. Required if enable_access_logging = true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply, typically the output of the mandatory-tags module."
  type        = map(string)
}
