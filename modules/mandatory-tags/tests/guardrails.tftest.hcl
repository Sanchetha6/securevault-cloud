variables {
  owner       = "platform-team"
  environment = "dev"
  cost_center = "CC-1234"
}

run "good_tags_are_produced" {
  command = plan

  assert {
    condition     = output.tags["Owner"] == "platform-team" && output.tags["Environment"] == "dev" && output.tags["CostCenter"] == "CC-1234"
    error_message = "The three mandatory tags must appear in the output."
  }

  assert {
    condition     = output.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy must always be terraform."
  }
}

run "extra_tags_cannot_override_mandatory_ones" {
  command = plan

  variables {
    extra_tags = {
      Owner   = "someone-else"
      Project = "demo"
    }
  }

  assert {
    condition     = output.tags["Owner"] == "platform-team"
    error_message = "extra_tags must never overwrite a mandatory tag."
  }

  assert {
    condition     = output.tags["Project"] == "demo"
    error_message = "extra_tags should still be merged in."
  }
}

run "invalid_environment_is_rejected" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}

run "empty_owner_is_rejected" {
  command = plan

  variables {
    owner = ""
  }

  expect_failures = [var.owner]
}

run "empty_cost_center_is_rejected" {
  command = plan

  variables {
    cost_center = ""
  }

  expect_failures = [var.cost_center]
}
