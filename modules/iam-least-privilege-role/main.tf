resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy_json
  tags               = var.tags

  # This is the REAL enforcement. A "check" block (used elsewhere in
  # variables.tf) only ever produces a warning and can never stop apply.
  # A lifecycle precondition on the resource itself causes a hard error
  # and genuinely blocks terraform plan/apply from proceeding.
  lifecycle {
    precondition {
      condition     = length(local.overly_broad_statements) == 0
      error_message = "inline_policy_json contains a statement with Action:\"*\" AND Resource:\"*\" — this grants unrestricted access to everything. Scope the action to specific API calls (e.g. s3:GetObject) and/or the resource to a specific ARN."
    }
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.this.id
  policy = var.inline_policy_json
}
