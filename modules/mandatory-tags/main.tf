locals {
  mandatory_tags = {
    Owner              = var.owner
    Environment        = var.environment
    CostCenter         = var.cost_center
    DataClassification = var.data_classification
    ManagedBy          = "terraform"
  }

  # extra_tags is merged in, but can never override a mandatory key.
  # This keeps the "secure by default" guarantee: nobody downstream
  # can accidentally (or deliberately) blank out a required tag.
  tags = merge(var.extra_tags, local.mandatory_tags)
}
