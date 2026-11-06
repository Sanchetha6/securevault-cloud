# ---- GOOD: passes the check, scoped to one bucket and specific actions ----
module "app_role_good" {
  source = "../../modules/iam-least-privilege-role"

  role_name = "app-read-only-role"
  assume_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  inline_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::sancheta-securevault-2026", "arn:aws:s3:::sancheta-securevault-2026/*"]
    }]
  })
  tags = module.tags.tags
}

# ---- BAD: uncomment to see terraform plan fail with the check's error message ----
# module "app_role_bad" {
#   source = "../../modules/iam-least-privilege-role"
#
#   role_name = "over-privileged-role"
#   assume_role_policy_json = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
#   inline_policy_json = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = "*"
#       Resource = "*"
#     }]
#   })
#   tags = module.tags.tags
# }
