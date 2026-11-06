mock_provider "aws" {}

variables {
  role_name = "test-role"
  tags      = { Owner = "tests" }

  assume_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

run "scoped_policy_is_accepted" {
  command = plan

  variables {
    inline_policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::my-bucket/*"]
      }]
    })
  }

  assert {
    condition     = aws_iam_role.this.name == "test-role"
    error_message = "A scoped policy should produce the role."
  }
}

run "wildcard_action_and_resource_is_rejected" {
  command = plan

  variables {
    inline_policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }]
    })
  }

  expect_failures = [aws_iam_role.this]
}

run "wildcard_in_list_form_is_rejected" {
  command = plan

  variables {
    inline_policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["*"]
        Resource = ["*"]
      }]
    })
  }

  expect_failures = [aws_iam_role.this]
}

run "wildcard_in_a_single_statement_object_is_rejected" {
  command = plan

  variables {
    inline_policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    })
  }

  expect_failures = [aws_iam_role.this]
}
