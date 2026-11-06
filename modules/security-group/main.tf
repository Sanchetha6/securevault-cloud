resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = var.tags

  # Rules are managed as separate resources below rather than inline blocks,
  # so that a `terraform plan` clearly shows exactly which rule changed.
  lifecycle {
    create_before_destroy = true

    # REAL enforcement — a lifecycle precondition causes a hard error and
    # genuinely blocks plan/apply. (The "check" block in variables.tf only
    # ever produces a warning and can never stop a deployment on its own.)
    precondition {
      condition     = length(local.disallowed_open_rules) == 0
      error_message = "One or more ingress_rules use 0.0.0.0/0 or ::/0 on a port not present in allow_public_ingress_ports. Either restrict the cidr_blocks to specific ranges, or add the port to allow_public_ingress_ports if public exposure is intentional (e.g. 443 on a public ALB)."
    }
  }
}

locals {
  # aws_vpc_security_group_ingress_rule/egress_rule each take exactly one
  # CIDR, so flatten "rule x cidr" into one map entry per (rule, cidr) pair.
  ingress_flat = {
    for pair in flatten([
      for idx, rule in var.ingress_rules : [
        for cidr in rule.cidr_blocks : {
          key         = "${idx}-${cidr}"
          description = rule.description
          from_port   = rule.from_port
          to_port     = rule.to_port
          protocol    = rule.protocol
          cidr        = cidr
        }
      ]
    ]) : pair.key => pair
  }

  egress_flat = {
    for pair in flatten([
      for idx, rule in var.egress_rules : [
        for cidr in rule.cidr_blocks : {
          key         = "${idx}-${cidr}"
          description = rule.description
          from_port   = rule.from_port
          to_port     = rule.to_port
          protocol    = rule.protocol
          cidr        = cidr
        }
      ]
    ]) : pair.key => pair
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress_flat

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.egress_flat

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
}
