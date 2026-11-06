output "tags" {
  description = "Merged map of mandatory + extra tags. Feed this into every resource's tags argument."
  value       = local.tags
}
