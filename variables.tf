locals {
  parent_node_types = [
    "ORGANISATIONS",
    "FOLDERS",
    "PROJECTS",
  ]

  /*trigger_actions = [
    "ALERT"
  ]*/
}

variable "feeds" {

  description = "GCP targets in the sens of ORGANISATIONS, FOLDERS or PROJECTS. Each target creates a new BQ dataset in the hosting_project_id which is feed with a specified recurency."

  # A possible target would be to define it as YAML file
  type = map(object({
    description        = string
    assets_parent_type = string
    assets_parent_id   = string

    # (optional) realtime or scheduled. If scheduled set a cron. realtime use feeds. schedule use cron job & a function which use the search all API
    # control_type       = string
    # filter             = string  # not really needed. Condition on the temporalAsset. if we realise we don't want to know about deletion for instance

    # valid types available here: https://cloud.google.com/asset-inventory/docs/supported-asset-types
    asset_type = string # we can do a regexp on it
    trigger_action = object({
      type   = string
      config = object({})
    })
  }))

  validation {
    condition     = alltrue([for v in values(var.feeds) : can(regex("[\\p{Ll}\\p{Lo}\\p{N}_-]{0,63}", v.description))])
    error_message = "Feed description should abide by the '[\\p{Ll}\\p{Lo}\\p{N}_-]{0,63}' regex"
  }
  validation {
    condition     = alltrue([for v in values(var.feeds) : contains(["ORGANISATIONS", "FOLDERS", "PROJECTS"], v.assets_parent_type)])
    error_message = "Extraction target type can only take value in ['ORGANISATIONS', 'FOLDERS', 'PROJECTS']"
  }

  validation {
    condition     = alltrue([for v in values(var.feeds) : contains(["ALERT"], v.trigger_action.type)])
    error_message = "Feed trigger_action type can only take value in ['ALERT']"
  }

  validation {
    condition     = alltrue([for v in values(var.feeds) : can(regex(".*googleapis.com/.*", v.asset_type))])
    error_message = "Feed asset_type are to be taken from 'https://cloud.google.com/asset-inventory/docs/supported-asset-types'"
  }

}

variable "feed_operators" {
  description = "Group or identity emails to give access to feed related logs and alerting. Must follow format https://cloud.google.com/billing/docs/reference/rest/v1/Policy#Binding"
  type        = list(string)
  default     = []
}

variable "hosting_project_id" {
  description = "GCP project id where to host the different 'extrations' specified in extraction_targets"
  type        = string
}

variable "labels" {
  description = "value"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region location of resources to create"
  type        = string
  default     = "europe-west1"
}
