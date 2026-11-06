plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Relaxed on purpose for this project:
rule "terraform_documented_outputs" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = false
}
