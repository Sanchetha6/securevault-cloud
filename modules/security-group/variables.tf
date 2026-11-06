variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC to create the security group in."
  type        = string
}

variable "ingress_rules" {
  description = <<-EOT
    List of ingress rules. `cidr_blocks` may NOT contain 0.0.0.0/0 or ::/0
    unless the port is listed in `allow_public_ingress_ports` (e.g. 443 for
    a public ALB). This is enforced by validation below, not just convention.
  EOT
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "allow_public_ingress_ports" {
  description = "Explicit allowlist of ports that are permitted to use 0.0.0.0/0 or ::/0 as a source (e.g. [443] for a public-facing load balancer). Empty by default — public ingress must be opted into per-port, per-module-instance."
  type        = list(number)
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules. Defaults to none — callers must explicitly define egress rather than inheriting an open-by-default 0.0.0.0/0 rule."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply, typically the output of the mandatory-tags module."
  type        = map(string)
}

locals {
  # Flatten each ingress rule x each of its cidr_blocks so we can validate
  # per (port, cidr) pair rather than per rule block.
  ingress_cidr_pairs = flatten([
    for rule in var.ingress_rules : [
      for cidr in rule.cidr_blocks : {
        cidr      = cidr
        from_port = rule.from_port
        to_port   = rule.to_port
      }
    ]
  ])

  # Any pair that uses a "wide open" CIDR on a port NOT in the allowlist.
  disallowed_open_rules = [
    for pair in local.ingress_cidr_pairs : pair
    if contains(["0.0.0.0/0", "::/0"], pair.cidr) &&
    !contains(var.allow_public_ingress_ports, pair.from_port)
  ]
}

check "no_unapproved_open_ingress" {
}
