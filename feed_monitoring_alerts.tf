/**
 * Created feeds may failed when sending data to pub/sub.
 * A "feed operator" is in charge to monitor the health of feed delivery by accessing the logs
 * and being mail notified through a dedicated alert policy.
 *
 * More info: https://cloud.google.com/asset-inventory/docs/monitoring-asset-changes#troubleshooting
 */


resource "google_project_iam_custom_role" "feeds_operator_role" {

  project = var.hosting_project_id

  role_id     = "feeds_operator"
  title       = "Feeds operator"
  description = "CRUD operations on cloud assets feeds"
  permissions = [
    "cloudasset.feeds.create",
    "cloudasset.feeds.delete",
    "cloudasset.feeds.get",
    "cloudasset.feeds.list",
    "cloudasset.feeds.update",
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list",
  ]
}

locals {
  feed_operator_roles = {
    log_viewer_role_id = "roles/logging.viewer"
    feed_crud_role_id  = google_project_iam_custom_role.feeds_operator_role.id
  }
}

resource "google_project_iam_binding" "feed_operators" {

  for_each = local.feed_operator_roles

  project = var.hosting_project_id
  role    = local.feed_operator_roles[each.key]

  members = var.feed_operators
}

resource "google_monitoring_alert_policy" "alert_policy" {

  project = var.hosting_project_id

  display_name          = "Feed topic sending alert"
  notification_channels = values(google_monitoring_notification_channel.mails)[*].id

  combiner = "OR"
  conditions {
    display_name = "feed topics sending failure"
    condition_threshold {
      # https://cloud.google.com/monitoring/api/v3/filters
      filter          = "resource.type = \"pubsub_topic\" AND (resource.labels.topic_id = monitoring.regex.full_match(\".*-feed\") AND resource.labels.project_id = \"${var.hosting_project_id}\") AND metric.type = \"pubsub.googleapis.com/topic/send_request_count\" AND metric.labels.response_class != \"success\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  depends_on = [google_project_service.project_services]
}

resource "google_monitoring_notification_channel" "mails" {

  for_each = toset(var.feed_operators)

  project = var.hosting_project_id

  display_name = "Mail Notification Channel for operator: ${each.value}"
  # valid type listed here https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.notificationChannelDescriptors/list
  type = "email"

  # does not support dynamic block. Loop over the resource itself
  labels = {
    email_address = each.value
  }

  force_delete = true
}
