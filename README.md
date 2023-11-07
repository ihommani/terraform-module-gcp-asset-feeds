[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

# Template module on [CLOUD_NAME]

This is an example template module which can be used as a base to create a new module.

In this section, a module should describe its purpose.

## Usage

```terraform
module "test" {
  source              = "github.com/lvmh-group-it/terraform-module-cloud-template?ref=vX"
  example_input       = "input"
  example_other_input = "other_input"
}

output "example_output" {
  value       = module.test.example_output
  description = "Output of the module"
}
```

## Versions

This module uses [Semantic Versioning](https://semver.org/).

Multiple git tags are used to track versions:

* `vX.Y.Z` is an exact version, and is never updated
* `vX.Y` is a minor version, and is updated when fixes are added
* `vX` is a major version, and is updated when new features are added.

When a breaking change is introduced, the major version is incremented and using `?ref=vX` is safe.

A changelog is available [here](CHANGELOG.md).

## Pre-commit

This template repository initiates with a `.pre-commit-config.yaml` which is a configuration file for the [pre-commit](https://pre-commit.com/) tool.  
It relies heavily on this dedicated [terraform hook repo](https://github.com/antonbabenko/pre-commit-terraform).  
To run it locally, you can either use the [standard way](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) by installing hooks or [through Docker](https://github.com/antonbabenko/pre-commit-terraform#how-to-install).  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_example_input"></a> [example\_input](#input\_example\_input) | Example input of the module | `string` | n/a | yes |
| <a name="input_example_other_input"></a> [example\_other\_input](#input\_example\_other\_input) | Other example input of the module | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_other_output"></a> [example\_other\_output](#output\_example\_other\_output) | Example other output of the module |
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Example output of the module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
