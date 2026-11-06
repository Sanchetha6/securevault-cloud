variable "role_name" {
  description = "Name of the IAM role."
  type        = string
}

variable "assume_role_policy_json" {
  description = "Trust policy JSON (who/what can assume this role), e.g. an EC2 or Lambda service principal."
  type        = string
}

variable "inline_policy_json" {
  description = "Inline permission policy JSON for this role. Must NOT contain a statement with Action:\"*\" combined with Resource:\"*\" — see the check block below."
  type        = string
}

variable "tags" {
  description = "Tags to apply, typically the output of the mandatory-tags module."
  type        = map(string)
}

locals {
  policy_doc = jsondecode(var.inline_policy_json)

  # A policy's "Statement" can legally be a single object OR a list of
  # objects. tolist() will error on a bare object, so try() falls through
  # to wrapping it in a list ourselves. (A plain ternary here breaks
  # Terraform's type checker because the two branches return different
  # types — object vs. list — which it refuses to unify.)
  statements = try(tolist(local.policy_doc.Statement), [local.policy_doc.Statement])

  # Flag any statement that is Effect=Allow AND uses "*" for Action AND "*" for Resource.
  # Action/Resource can each be a string or a list, so normalize both to lists first.
  overly_broad_statements = [
    for s in local.statements : s
    if try(s.Effect, "") == "Allow" &&
    contains(flatten([try(s.Action, [])]), "*") &&
    contains(flatten([try(s.Resource, [])]), "*")
  ]
}
