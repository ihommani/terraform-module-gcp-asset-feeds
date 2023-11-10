
output "bq_data_sink_dataset" {
  value       = google_bigquery_dataset.data_sink.id
  description = "Location of the Bigquery Dataset containing table where selected feed events are exported vanilla"
}

output "bq_data_sink_table" {
  value       = google_bigquery_dataset.data_sink.id
  description = "Location of the Bigquery table where selected feed events are exported vanilla"
}

output "organisation_feeds" {
  value       = values(google_cloud_asset_organization_feed.organisation_feeds)[*].id
  description = "Organisation level feed"
}

output "folder_feeds" {
  value       = values(google_cloud_asset_folder_feed.folder_feeds)[*].id
  description = "Organisation folder level feed"
}

output "project_feeds" {
  value       = values(google_cloud_asset_project_feed.project_feeds)[*].id
  description = "Project level feed"
}

output "examples_get_feed_cli" {
  value       = "gcloud asset feeds describe <FEED_ID> --project=${var.hosting_project_id} --billing-project=${var.hosting_project_id}"
  description = "Gcloud command line example to get feed info. Feed are not accessible from the cloud console."
}

output "monitoring_feed_alert" {
  value       = google_monitoring_alert_policy.alert_policy.id
  description = "Feed failures alert policy"
}
