mock_provider "aws" {}

variables {
  name   = "test-sg"
  vpc_id = "vpc-0123456789abcdef0"
  tags   = { Owner = "tests" }
}

run "good_config_is_accepted" {
  command = plan

  variables {
    ingress_rules = [
      {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "SSH from office VPN only"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["203.0.113.0/24"]
      }
    ]

    allow_public_ingress_ports = [443]
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 2
    error_message = "Both rules should be planned."
  }
}

run "ssh_open_to_the_world_is_rejected" {
  command = plan

  variables {
    ingress_rules = [
      {
        description = "SSH from anywhere (BAD)"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]

    allow_public_ingress_ports = [443]
  }

  expect_failures = [aws_security_group.this]
}

run "public_port_not_on_the_allowlist_is_rejected" {
  command = plan

  variables {
    ingress_rules = [
      {
        description = "HTTPS from anywhere but not allow-listed"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  expect_failures = [aws_security_group.this]
}

run "no_ingress_rules_means_no_ingress" {
  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.this) == 0
    error_message = "With no ingress_rules, nothing should be opened."
  }
}
