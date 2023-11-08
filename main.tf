locals {
  service_apis = [
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "compute.googleapis.com",
    "monitoring.googleapis.com",
    "bigquery.googleapis.com",
  ]
}


resource "google_project_service" "project_services" {

  for_each = toset(local.service_apis)

  project                    = var.hosting_project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = true
}
