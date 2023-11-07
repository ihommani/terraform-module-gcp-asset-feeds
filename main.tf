terraform {
  required_version = ">= 1.5.0"
}

locals {
  example_ouptut       = "The input is : ${var.example_input}"
  example_other_ouptut = "The input is : ${var.example_other_input}"
}
