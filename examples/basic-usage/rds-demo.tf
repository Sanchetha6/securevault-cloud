# ---- GOOD: encrypted, private, 7-day backups. Safe to run `terraform plan`.
# Do NOT `terraform apply` this one: a database costs money and needs a real
# DB subnet group. `plan` alone is enough proof for the demo.
module "app_db_good" {
  source = "../../modules/rds-secure-instance"

  identifier = "securevault-demo-db"
  db_name    = "appdb"

  db_subnet_group_name   = "default" # replace with a real DB subnet group if you ever apply
  vpc_security_group_ids = [module.web_sg.security_group_id]

  backup_retention_period = 7
  deletion_protection     = false # sandbox only
  skip_final_snapshot     = true  # sandbox only

  tags = module.tags.tags
}

# ---- BAD: uncomment to see terraform plan fail (backups below the 7-day minimum) ----
# module "app_db_bad" {
#   source = "../../modules/rds-secure-instance"
#
#   identifier = "securevault-bad-db"
#   db_name    = "appdb"
#
#   db_subnet_group_name   = "default"
#   vpc_security_group_ids = [module.web_sg.security_group_id]
#
#   backup_retention_period = 1
#
#   tags = module.tags.tags
# }
