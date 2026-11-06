# Secure-by-Default Terraform Module Library

Three composable modules that make the *insecure* configuration the harder path,
not just the discouraged one.

```
modules/
  mandatory-tags/      # Enforces required tags on everything
  s3-secure-bucket/     # Encrypted, private, versioned S3 buckets
  security-group/       # Security groups that reject unapproved 0.0.0.0/0 ingress
examples/
  basic-usage/           # Wires all three together
```

## Design principle

Each module is built so the *dangerous* configuration requires extra, explicit
effort — not just a variable you forgot to set.

| Module | What's insecure-by-default in vanilla Terraform | How this module prevents it |
|---|---|---|
| `s3-secure-bucket` | Buckets can be made public via ACL/policy; encryption is opt-in | `aws_s3_bucket_public_access_block` is hardcoded with no variable to disable it. SSE is mandatory — you choose KMS or AES256, never "none." A bucket policy denies any request over plain HTTP. |
| `security-group` | Nothing stops `0.0.0.0/0` on any port, including SSH/RDP | A `lifecycle precondition` on the security group resource checks every ingress rule at plan-time; any rule using `0.0.0.0/0`/`::/0` on a port **not** explicitly listed in `allow_public_ingress_ports` causes a hard error that blocks `terraform plan`/`apply`. |
| `mandatory-tags` | Tags are usually a convention, not enforced | `owner`, `environment`, `cost_center` are required arguments with `validation` blocks — no defaults, so the plan fails without them. `extra_tags` is merged so it can never overwrite the mandatory keys. |

## Usage

```hcl
module "tags" {
  source      = "./modules/mandatory-tags"
  owner       = "platform-team@example.com"
  environment = "prod"
  cost_center = "CC-1234"
}

module "bucket" {
  source      = "./modules/s3-secure-bucket"
  bucket_name = "my-app-data-prod"
  tags        = module.tags.tags
}

module "sg" {
  source = "./modules/security-group"
  name   = "web-sg"
  vpc_id = "vpc-xxxxxxxx"

  ingress_rules = [{
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
  allow_public_ingress_ports = [443]  # opt-in, per port

  tags = module.tags.tags
}
```

Full working example: `examples/basic-usage/main.tf`.

## Testing before you trust it

I wrote this HCL carefully but **could not run `terraform validate` or `terraform plan`
in this environment** (no network access to the Terraform provider registry from here).
Before using this in a real account:

```bash
cd examples/basic-usage
terraform init
terraform validate
terraform plan   # requires AWS credentials; review the plan carefully
```

Also worth doing:
- Run `tflint` and/or `checkov`/`tfsec` against the modules — good complements to the
  hand-rolled `lifecycle precondition` checks, and they'll catch things this library doesn't (e.g. IAM
  policy analysis).
- If you want the guardrails enforced at the *organization* level (not just for people
  who happen to use these modules), pair this with **AWS Config conformance packs** or
  **Service Control Policies** — Terraform modules only protect callers who opt in.

## Extending this library

Natural next modules to add, following the same pattern:
- `rds-secure-instance` — encryption at rest, no public accessibility, mandatory backup retention
- `iam-least-privilege-role` — deny wildcard `Action: "*"` / `Resource: "*"` combos via a `lifecycle precondition`
- `cloudtrail-org-trail` — mandatory multi-region trail with log file validation and a locked-down S3 destination

Each should follow the same rule this library uses: **the insecure option should not
exist as a flag** — if something needs to be open, the caller has to declare it loudly
and per-instance (like `allow_public_ingress_ports` here), not just fail to set a
"secure" switch.
